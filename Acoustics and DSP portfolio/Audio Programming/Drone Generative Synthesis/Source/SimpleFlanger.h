#pragma once
#include <JuceHeader.h>

/*
    SimpleFlanger

    Short modulated delay creates a moving comb-filter ("jet" sweep).

    y[n] = x[n] + g * x[n - M[n]]
    M[n] = M0 * (1 + a * sin(...))
*/

class SimpleFlanger
{
public:
    void prepare(double fs, float delayTimeSec, float f0Hz, float gIn, float aIn)
    {
        sampleRate = (float)fs;
        gain = gIn;
        depth = aIn;
        f0 = f0Hz;

        // Convert seconds -> samples so delay time is sample-accurate.
        int Mmax = (int)std::round(delayTimeSec * sampleRate);
        if (Mmax < 1) Mmax = 1;

        maxDelay = Mmax;
        M0 = 0.5f * (float)Mmax;

        size = maxDelay + 1;
        if (size > (int)maxSize) size = (int)maxSize;

        for (int i = 0; i < size; ++i) buf[i] = 0.0f;

        writeIndex = 0;
        phase = 0.0f;
    }

    float process(float x)
    {
        float lfo = std::sin(phase * juce::MathConstants<float>::twoPi);

        // Phase increment in cycles/sample (phase is normalised 0..1).
        phase += f0 / sampleRate;
        if (phase > 1.0f) phase -= 1.0f;

        int M = (int)std::round(M0 * (1.0f + depth * lfo));
        if (M < 1) M = 1;
        if (M > maxDelay) M = maxDelay;

        // Circular buffer read for "M samples ago".
        int readIndex = writeIndex - M;
        while (readIndex < 0) readIndex += size;

        float delayed = buf[readIndex];
        float y = x + gain * delayed;

        buf[writeIndex] = x;
        writeIndex++;
        if (writeIndex >= size) writeIndex = 0;

        return y;
    }

private:
    static constexpr int maxSize = 48000;
    float buf[maxSize]{};

    int size = 1;
    int writeIndex = 0;

    float sampleRate = 44100.0f;
    float phase = 0.0f;

    float f0 = 0.2f;
    float gain = 0.2f;
    float depth = 1.0f;

    int maxDelay = 1;
    float M0 = 1.0f;
};