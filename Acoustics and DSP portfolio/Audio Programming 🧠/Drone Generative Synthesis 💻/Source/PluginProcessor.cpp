#include "PluginProcessor.h"
#include "PluginEditor.h"
#include <cmath>

Drone2AudioProcessor::Drone2AudioProcessor()
#ifndef JucePlugin_PreferredChannelConfigurations
    : AudioProcessor(BusesProperties()
#if ! JucePlugin_IsMidiEffect
#if ! JucePlugin_IsSynth
        .withInput("Input", juce::AudioChannelSet::stereo(), true)
#endif
        .withOutput("Output", juce::AudioChannelSet::stereo(), true)
#endif
    )
#endif
{
}

Drone2AudioProcessor::~Drone2AudioProcessor() {}

const juce::String Drone2AudioProcessor::getName() const { return JucePlugin_Name; }

bool Drone2AudioProcessor::acceptsMidi() const
{
#if JucePlugin_WantsMidiInput
    return true;
#else
    return false;
#endif
}

bool Drone2AudioProcessor::producesMidi() const
{
#if JucePlugin_ProducesMidiOutput
    return true;
#else
    return false;
#endif
}

bool Drone2AudioProcessor::isMidiEffect() const
{
#if JucePlugin_IsMidiEffect
    return true;
#else
    return false;
#endif
}

double Drone2AudioProcessor::getTailLengthSeconds() const { return 0.0; }

int Drone2AudioProcessor::getNumPrograms() { return 1; }
int Drone2AudioProcessor::getCurrentProgram() { return 0; }
void Drone2AudioProcessor::setCurrentProgram(int index) { juce::ignoreUnused(index); }
const juce::String Drone2AudioProcessor::getProgramName(int index) { juce::ignoreUnused(index); return {}; }
void Drone2AudioProcessor::changeProgramName(int index, const juce::String& newName) { juce::ignoreUnused(index, newName); }

static float midiToHz(float midi)
{
    // MIDI note -> Hz. Easier to write/adjust chord voicings using MIDI note numbers.
    return 440.0f * std::pow(2.0f, (midi - 69.0f) / 12.0f);
}

static void setChord(std::vector<Oscillator>& oscs, int chordState)
{
    // Two harmonic states. Alternating them creates long-form evolution without UI controls.
    float Amaj7[6] = { 45, 49, 52, 56, 57, 64 }; // A C# E G# A E
    float Dmaj7[6] = { 50, 54, 57, 61, 62, 69 }; // D F# A C# D A

    for (int i = 0; i < 6; ++i)
    {
        float m = (chordState == 0) ? Amaj7[i] : Dmaj7[i];
        oscs[i].setFrequency(midiToHz(m));
    }
}

void Drone2AudioProcessor::prepareToPlay(double sampleRate, int samplesPerBlock)
{
    juce::ignoreUnused(samplesPerBlock);

    sampleRateHz = sampleRate;

    chordOscs.clear();
    chordOscs.resize(6);

    for (int i = 0; i < (int)chordOscs.size(); ++i)
    {
        chordOscs[i].setSampleRate((float)sampleRateHz);
        chordOscs[i].setWaveType(0); // sine keeps the drone clean/tonal
    }

    chordState = 0;

    // Timing in samples gives stable, sample-accurate scheduling (not dependent on block size).
    samplesUntilChordChange = (int)(sampleRateHz * (45.0 + random.nextFloat() * 45.0));

    // Slow fade-in avoids a hard start and helps the texture “arrive”.
    masterAmp = 0.0f;
    masterAmpStep = 1.0f / (float)(sampleRateHz * 25.0f);

    tremLFO.setSampleRate((float)sampleRateHz);
    tremLFO.setFrequency(0.12f);
    tremLFO.setWaveType(1);

    panLFO.setSampleRate((float)sampleRateHz);
    panLFO.setFrequency(0.02f);
    panLFO.setWaveType(0);

    resonators.clear();
    resonators.resize(6);

    for (int i = 0; i < (int)resonators.size(); ++i)
    {
        // Band-pass bank adds shimmer/detail so the drone doesn’t feel static.
        float f = 2200.0f + 900.0f * (float)i;
        resonators[i].setCoefficients(juce::IIRCoefficients::makeBandPass(sampleRateHz, f, 2.6f));
    }

    chorusL.prepare(sampleRateHz, 0.020f, 0.005f, 0.5f, 0.6f, 0.030f, 0.007f, 0.7f, 0.6f);
    chorusR.prepare(sampleRateHz, 0.020f, 0.005f, 0.5f, 0.6f, 0.030f, 0.007f, 0.7f, 0.6f);

    flangerL.prepare(sampleRateHz, 0.005f, 0.08f, 0.25f, 1.0f);
    flangerR.prepare(sampleRateHz, 0.005f, 0.09f, 0.25f, 1.0f);

    wetLFO.setSampleRate((float)sampleRateHz);
    wetLFO.setFrequency(0.008f);
    wetLFO.setWaveType(0);

    noiseGateLFO.setSampleRate((float)sampleRateHz);
    noiseGateLFO.setFrequency(0.08f);
    noiseGateLFO.setWaveType(2);

    noiseLP.setCoefficients(juce::IIRCoefficients::makeLowPass(sampleRateHz, 2500.0));

    totalSamplesProcessed = 0;
    fadingOut = false;
}

void Drone2AudioProcessor::releaseResources() {}

#ifndef JucePlugin_PreferredChannelConfigurations
bool Drone2AudioProcessor::isBusesLayoutSupported(const BusesLayout& layouts) const
{
#if JucePlugin_IsMidiEffect
    juce::ignoreUnused(layouts);
    return true;
#else
    if (layouts.getMainOutputChannelSet() != juce::AudioChannelSet::mono()
        && layouts.getMainOutputChannelSet() != juce::AudioChannelSet::stereo())
        return false;

#if ! JucePlugin_IsSynth
    if (layouts.getMainOutputChannelSet() != layouts.getMainInputChannelSet())
        return false;
#endif

    return true;
#endif
}
#endif

void Drone2AudioProcessor::processBlock(juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages)
{
    juce::ignoreUnused(midiMessages);
    juce::ScopedNoDenormals noDenormals;

    const auto totalNumInputChannels = getTotalNumInputChannels();
    const auto totalNumOutputChannels = getTotalNumOutputChannels();

    // Clear extra output channels (JUCE safety when more outputs than inputs).
    for (auto ch = totalNumInputChannels; ch < totalNumOutputChannels; ++ch)
        buffer.clear(ch, 0, buffer.getNumSamples());

    const int numSamples = buffer.getNumSamples();
    const int numChannels = buffer.getNumChannels();

    auto* leftChannel = buffer.getWritePointer(0);
    auto* rightChannel = (numChannels > 1) ? buffer.getWritePointer(1) : nullptr;

    // Save the starting sample index for this block (used for per-sample fade timing).
    const long long blockStartSample = totalSamplesProcessed;
    totalSamplesProcessed += numSamples;

    // Fade timing in samples
    const long long fadeStartSamples = (long long)(fadeStartSeconds * sampleRateHz);
    const long long fadeDurationSamples = (long long)(fadeDurationSeconds * sampleRateHz);

    if (totalSamplesProcessed >= fadeStartSamples)
        fadingOut = true;

    // Chord scheduling (in samples) + randomised duration prevents predictable looping.
    samplesUntilChordChange -= numSamples;
    if (samplesUntilChordChange <= 0)
    {
        chordState = 1 - chordState;
        samplesUntilChordChange = (int)(sampleRateHz * (45.0 + random.nextFloat() * 45.0));
    }

    setChord(chordOscs, chordState);

    const float w = wetLFO.process(); // [-1,1]
    // Map [-1,1] -> [0,1], then scale to subtle wet range so FX never fully dominates.
    const float wet = 0.15f + 0.20f * (w * 0.5f + 0.5f);

    for (int i = 0; i < numSamples; ++i)
    {
        float s = 0.0f;

        for (int j = 0; j < (int)chordOscs.size(); ++j)
            s += chordOscs[j].process();

        // Fade-in (avoid sudden start)
        if (masterAmp < 1.0f) masterAmp += masterAmpStep;
        if (masterAmp > 1.0f) masterAmp = 1.0f;
        s *= masterAmp;

        // Normalise sum of oscillators
        s *= 0.50f;

        // Tremolo
        const float t = tremLFO.process();
        const float tremGain = 0.85f + 0.15f * (t * 0.5f + 0.5f);
        s *= tremGain;

        // Resonator shimmer
        float sparkle = 0.0f;
        for (int k = 0; k < (int)resonators.size(); ++k)
            sparkle += resonators[k].processSingleSampleRaw(s * 0.30f);

        s += sparkle * 0.10f;

        // Noise layer 
        const float n = (random.nextFloat() * 2.0f - 1.0f);

        const float g = noiseGateLFO.process();
        const float gate01 = (g > 0.0f) ? 1.0f : 0.0f;
        const float gate = 0.20f + 0.80f * gate01;

        float noise = n * 0.015f * gate;
        noise = noiseLP.processSingleSampleRaw(noise);
        s += noise;

        // Equal-power panning keeps perceived loudness more consistent during stereo movement.
        const float p = panLFO.process();
        const float angle = (p * 0.5f + 0.5f) * juce::MathConstants<float>::halfPi;

        // Fade-out (per-sample timing so it’s smooth)
        if (fadingOut)
        {
            const long long currentSample = blockStartSample + i;
            const long long fadePosition = currentSample - fadeStartSamples;

            if (fadePosition >= 0 && fadePosition < fadeDurationSamples)
            {
                float fadeAmount = 1.0f - (float)fadePosition / (float)fadeDurationSamples;
                fadeAmount *= fadeAmount; // gentle curve
                s *= fadeAmount;
            }
            else if (fadePosition >= fadeDurationSamples)
            {
                s = 0.0f;
            }
        }

        float L = std::cos(angle) * s;
        float R = std::sin(angle) * s;

        // FX chain
        const float wl = flangerL.process(chorusL.process(L));
        const float wr = flangerR.process(chorusR.process(R));

        L = (1.0f - wet) * L + wet * wl;
        R = (1.0f - wet) * R + wet * wr;

        leftChannel[i] = L;

        if (rightChannel != nullptr)
            rightChannel[i] = R;
        else
            leftChannel[i] = 0.5f * (L + R); // mono-safe
    }
}

bool Drone2AudioProcessor::hasEditor() const { return true; }

juce::AudioProcessorEditor* Drone2AudioProcessor::createEditor()
{
    return new Drone2AudioProcessorEditor(*this);
}

void Drone2AudioProcessor::getStateInformation(juce::MemoryBlock& destData)
{
    juce::ignoreUnused(destData);
}

void Drone2AudioProcessor::setStateInformation(const void* data, int sizeInBytes)
{
    juce::ignoreUnused(data, sizeInBytes);
}

juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new Drone2AudioProcessor();
}