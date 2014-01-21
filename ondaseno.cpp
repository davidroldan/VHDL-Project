/**
 * @file ondaseno.cpp
 * @brief Reproductor de sonido.
 *
 * @note Basado en paex_sine_c++.cpp por Ross Bencina y Phil Burk.
 */

#include <iostream>
#include <limits>
#include <cmath>
#include "ondaseno.h"

using namespace std;

#ifndef M_PI
	const double M_PI = 3.14159265;
#endif

const double SAMPLE_RATE = 44100 * 4;

OndaSeno::OndaSeno(unsigned int tamTabla) : _tamTabla(tamTabla), _frecuencia(numeric_limits<double>::infinity()),
	_leftPhase(0), _rightPhase(0) {
	
	// Nada que hacer
}

OndaSeno::~OndaSeno() {
}

void OndaSeno::fijarFrecuencia(float f){
	_frecuencia = (double) f;

	_tamTabla = TABLE_SIZE * (44000.0  / _frecuencia);
}

// :: Funciones privadas ::

float OndaSeno::valorOnda(unsigned int n) {
	if (_frecuencia == numeric_limits<double>::infinity())
		return 0;
	else {
		return sin(( (double) n / (double) _tamTabla) * M_PI * 2.0);
	}
}

/* The instance callback, where we have access to every method/variable in object of class Sine */
int OndaSeno::generate(const void * /* inputBuffer */,
	void *outputBuffer,
	unsigned long framesPerBuffer,
	const PaStreamCallbackTimeInfo* /* timeInfo */,
	PaStreamCallbackFlags /* statusFlags */
) {
	// assert(outputBuffer != NULL);

	float **out = static_cast<float **>(outputBuffer);

	for (unsigned int i = 0; i < framesPerBuffer; i++)
	{
		out[0][i] = valorOnda(_leftPhase);
		out[1][i] = valorOnda(_rightPhase);

		_leftPhase += 1;

		if (_leftPhase >= _tamTabla)
			_leftPhase -= _tamTabla;

		_rightPhase += 3;

		if (_rightPhase >= _tamTabla)
			_rightPhase -= _tamTabla;
	}

	return paContinue;
}
