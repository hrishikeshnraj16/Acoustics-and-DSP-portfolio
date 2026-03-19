#pragma once
#include <JuceHeader.h>

/*
    SimpleChorus

    Uses two slowly modulated delay taps to thicken the signal.

    y[n] = x[n] + g1*x[n-M1[n]] + g2*x[n-M2[n]]
    M1[n] = P01 + D1*sin(...)
    M2[n] = P02 + D2*sin(...)
*/

class SimpleChorus
{
public:
    void prepare(double fs,
        float delay1Sec, float swing1Sec, float f1Hz, float g1In,
        float delay2Sec, float swing2Sec, float f2Hz, float g2In)
    {
        sampleRate = (float)fs;

        g1 = g1In; g2 = g2In;
        f1 = f1Hz; f2 = f2Hz;

        // Convert seconds -> samples (DSP works in samples, not seconds).
        P01 = delay1Sec * sampleRate;
        D1 = swing1Sec * sampleRate;

        P02 = delay2Sec * sampleRate;
        D2 = swing2Sec * sampleRate;

        int maxDelay = (int)std::ceil(std::max(P01 + std::abs(D1), P02 + std::abs(D2)));
        if (maxDelay < 1) maxDelay = 1;

        size = maxDelay + 1;
        if (size > (int)maxSize) size = (int)maxSize;

        for (int i = 0; i < size; ++i) buf[i] = 0.0f;

        writeIndex = 0;
        ph1 = 0.0f;
        ph2 = 0.0f;
    }

    float process(float x)
    {
        float lfo1 = std::sin(ph1 * juce::MathConstants<float>::twoPi);
        float lfo2 = std::sin(ph2 * juce::MathConstants<float>::twoPi);

        // Phase increment in cycles/sample (phase is normalised 0..1).
        ph1 += f1 / sampleRate; if (ph1 > 1.0f) ph1 -= 1.0f;
        ph2 += f2 / sampleRate; if (ph2 > 1.0f) ph2 -= 1.0f;

        int M1 = (int)std::round(P01 + D1 * lfo1);
        int M2 = (int)std::round(P02 + D2 * lfo2);

        if (M1 < 1) M1 = 1; if (M1 > size - 1) M1 = size - 1;
        if (M2 < 1) M2 = 1; if (M2 > size - 1) M2 = size - 1;

        float d1s = readDelay(M1);
        float d2s = readDelay(M2);

        float y = x + g1 * d1s + g2 * d2s;

        buf[writeIndex] = x;
        writeIndex++;
        if (writeIndex >= size) writeIndex = 0;

        return y;
    }

private:
    float readDelay(int M)
    {
        // Circular buffer indexing: avoids shifting memory every sample.
        int idx = writeIndex - M;
        while (idx < 0) idx += size;
        return buf[idx];
    }

private:
    static constexpr int maxSize = 48000;
    float buf[maxSize]{};

    int size = 1;
    int writeIndex = 0;

    float sampleRate = 44100.0f;

    float ph1 = 0.0f, ph2 = 0.0f;
    float f1 = 0.5f, f2 = 0.7f;

    float g1 = 0.6f, g2 = 0.6f;

    float P01 = 0.0f, D1 = 0.0f;
    float P02 = 0.0f, D2 = 0.0f;
};