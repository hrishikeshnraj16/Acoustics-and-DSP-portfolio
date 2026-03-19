#pragma once
#include <JuceHeader.h>
#include <cmath>

/*
    Oscillator
*/

class Oscillator
{
public:
    void setSampleRate(float sr)
    {
        sampleRate = sr;
        updatePhaseDelta();
    }

    void setFrequency(float freq)
    {
        frequency = freq;
        updatePhaseDelta();
    }

    void setWaveType(int type)
    {
        // Clamp to valid range so we never select an invalid waveform.
        waveType = juce::jlimit(0, 3, type);
    }

    float process()
    {
        float output = 0.0f;

        switch (waveType)
        {
        case 0: // sine (clean tone / smooth LFO)
            output = std::sin(phase * juce::MathConstants<float>::twoPi);
            break;

        case 1: // triangle (soft movement)
            output = 2.0f * std::abs(2.0f * phase - 1.0f) - 1.0f;
            break;

        case 2: // square (hard on/off modulation)
            output = (phase < 0.5f) ? 1.0f : -1.0f;
            break;

        case 3: // saw (bright harmonic tone)
            output = 2.0f * phase - 1.0f;
            break;

        default:
            break;
        }

        phase += phaseDelta;
        if (phase >= 1.0f)
            phase -= 1.0f;

        return output;
    }

private:
    void updatePhaseDelta()
    {
        if (sampleRate > 0.0f)
            phaseDelta = frequency / sampleRate;
    }

    float sampleRate = 44100.0f;
    float frequency = 440.0f;

    float phase = 0.0f;
    float phaseDelta = 0.0f;

    int waveType = 0;
};