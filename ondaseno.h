/**
 * @file ondaseno.h
 *
 * @brief Generador de onda seno.
 */

#ifndef ONDASENO_H
#define ONDASENO_H

#include "portaudio.h"

const unsigned int SAMPLE_RATE = 44100;
const unsigned int TABLE_SIZE = 200;

/**
 * @brief Reproduce una onda sinusoidal de una frecuencia determinada.
 */
class OndaSeno {
public:
	/**
	 * @brief Crea un objeto onda-seno.
	 */
	OndaSeno(unsigned int sampleRate = SAMPLE_RATE);

	/**
	 * @brief Abre un flujo de PortAudio para la reproducción.
	 *
	 * @param index Índice del dispositivo de reproducción.
	 */
	bool open(PaDeviceIndex index);

	/**
	 * @brief Cierra el flujo de PortAudio asociado.
	 */
	bool close();

	/**
	 * @brief Comienza la reproducción de la onda.
	 */
	bool start();

	/**
	 * @brief Detiene la reproducción de la onda.
	 */
	bool stop();

private:
	// :: Métodos privados :: Alcantarillas de la clase
	int paCallbackMethod(const void *, void *, unsigned long,
		const PaStreamCallbackTimeInfo*, PaStreamCallbackFlags);
	static int paCallback(const void *, void *, unsigned long, const PaStreamCallbackTimeInfo*,
		PaStreamCallbackFlags, void *);
	void paStreamFinishedMethod();
	static void paStreamFinished(void*);

	// :: Atributos ::

	// Flujo de PortAudio
	PaStream *_stream;
	// Tabla de seno
	float _sine[TABLE_SIZE];
	// Fase del canal izquierdo
	unsigned int _left_phase;
	// Fase del canal derecho
	unsigned int _right_phase;

	// Tasa de muestra
	unsigned int _sampleRate;
};

#endif // ONDASENO_H
