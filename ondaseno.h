/**
 * @file ondaseno.h
 *
 * @brief Generador de onda seno.
 */

#ifndef ONDASENO_H
#define ONDASENO_H

#include "portaudio.h"

/**
 * @brief Reproduce una onda sinusoidal de una frecuencia determinada.
 */
class OndaSeno {
public:
	/**
	 * @brief Crea un objeto onda-seno.
	 *
	 */
	OndaSeno();

	/**
	 * @brief Libera los recursos capturados.
	 */
	~OndaSeno();

	/**
	 * @brief Fija la frecuencia de la onda.
	 *
	 * @param f Frecuencia de onda.
	 */
	void fijarFrecuencia(float f);

	// Método llamado por el sistema de PortAudio
	int generate(const void *, void *, unsigned long,
		const PaStreamCallbackTimeInfo*, PaStreamCallbackFlags);

private:
	// Genera la tabla de onda
	float valorOnda(unsigned int n);

	// :: Atributos ::

	// Tamaño de la tabla (ficticia)
	unsigned int _tamTabla;

	// Frecuencia
	double _frecuencia;

	// Fase del canal izquierdo
	unsigned int _leftPhase;
	// Fase del canal derecho
	unsigned int _rightPhase;
};

#endif // ONDASENO_H
