#pragma once

#include <JuceHeader.h>
#include "Oscillator.h"
#include <vector>
#include "SimpleChorus.h"
#include "SimpleFlanger.h"

class Drone2AudioProcessor : public juce::AudioProcessor
{
public:
    Drone2AudioProcessor();
    ~Drone2AudioProcessor() override;

    void prepareToPlay(double sampleRate, int samplesPerBlock) override;
    void releaseResources() override;

#ifndef JucePlugin_PreferredChannelConfigurations
    bool isBusesLayoutSupported(const BusesLayout& layouts) const override;
#endif

    void processBlock(juce::AudioBuffer<float>&, juce::MidiBuffer&) override;

    juce::AudioProcessorEditor* createEditor() override;
    bool hasEditor() const override;

    const juce::String getName() const override;

    bool acceptsMidi() const override;
    bool producesMidi() const override;
    bool isMidiEffect() const override;
    double getTailLengthSeconds() const override;

    int getNumPrograms() override;
    int getCurrentProgram() override;
    void setCurrentProgram(int index) override;
    const juce::String getProgramName(int index) override;
    void changeProgramName(int index, const juce::String& newName) override;

    void getStateInformation(juce::MemoryBlock& destData) override;
    void setStateInformation(const void* data, int sizeInBytes) override;

private:
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(Drone2AudioProcessor)

        double sampleRateHz = 44100.0;

    // Multi-osc chord drone: each oscillator is one chord tone.
    std::vector<Oscillator> chordOscs;

    // Alternates between two harmonic states to create long-form evolution.
    int chordState = 0;
    int samplesUntilChordChange = 0;

    // Fade-in avoids a sudden “start click” and makes the entry feel intentional.
    float masterAmp = 0.0f;
    float masterAmpStep = 0.0f;

    // Slow modulation sources (LFOs).
    Oscillator tremLFO;
    Oscillator panLFO;
    Oscillator wetLFO;

    // Band-pass bank adds high-frequency shimmer/detail.
    std::vector<juce::IIRFilter> resonators;

    SimpleChorus chorusL, chorusR;
    SimpleFlanger flangerL, flangerR;

    // Low-level filtered noise adds air/texture.
    Oscillator noiseGateLFO;
    juce::IIRFilter noiseLP;

    juce::Random random;

    // Track total elapsed samples since start.
    long long totalSamplesProcessed = 0;

    // After this many seconds, begin fade-out.
    double fadeStartSeconds = 180;   // 3 minutes

    // Fade-out duration.
    double fadeDurationSeconds = 25; // 25 second fade

    bool fadingOut = false;
};