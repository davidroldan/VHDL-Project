/**
 * @file ondaseno.cpp
 * @brief Reproductor de sonido.
 *
 * @note Basado en paex_sine_c++.cpp por Ross Bencina y Phil Burk.
 */

#include <iostream>
#include <cmath>
#include "ondaseno.h"

using namespace std;

const unsigned int NUM_SECONDS = 1;
const unsigned int FRAMES_PER_BUFFER = 64;


#ifndef M_PI
	const double M_PI = 3.14159265;
#endif


OndaSeno::OndaSeno(unsigned int sampleRate) : _stream(0), _left_phase(0), _right_phase(0), _sampleRate(sampleRate) {

	// Crea la tabla de onda sinusoidal

	for (unsigned int i = 0; i < TABLE_SIZE; i++) {
		_sine[i] = sin( ( (double) i / (double) TABLE_SIZE ) * M_PI * 2.0 );
	}
}

bool OndaSeno::open(PaDeviceIndex index) {
	PaStreamParameters outputParameters;

	outputParameters.device = index;

	if (outputParameters.device == paNoDevice) {
		return false;
	}

	outputParameters.channelCount = 2;	   // salida estéreo
	outputParameters.sampleFormat = paFloat32; // salida de punto flotante de 32 bit
	outputParameters.suggestedLatency = Pa_GetDeviceInfo( outputParameters.device )->defaultLowOutputLatency;
	outputParameters.hostApiSpecificStreamInfo = NULL;

	PaError err = Pa_OpenStream(
		&_stream,
		NULL,			// es sólo para salida
		&outputParameters,
		_sampleRate,
		FRAMES_PER_BUFFER,
		paClipOff,		// no importa cortar la salida porque mantendremos las muestras dentro de los rangos
		&OndaSeno::paCallback,
		this			// Pasa this como userData
	);

	if (err != paNoError) {
		/* Failed to open stream to device !!! */
		return false;
	}

	err = Pa_SetStreamFinishedCallback(_stream, &OndaSeno::paStreamFinished);

	if (err != paNoError) {
		Pa_CloseStream(_stream);
		_stream = 0;

		return false;
	}

	return true;
}

bool OndaSeno::close() {
	if (_stream == 0)
		return false;

	PaError err = Pa_CloseStream(_stream);
	_stream = 0;

	return (err == paNoError);
}


bool OndaSeno::start() {
	if (_stream == 0)
		return false;

	PaError err = Pa_StartStream(_stream);

	return (err == paNoError);
}

bool OndaSeno::stop() {
	if (_stream == 0)
		return false;

	PaError err = Pa_StopStream(_stream);

	return (err == paNoError);
}


// :: Funciones privadas ::

/* The instance callback, where we have access to every method/variable in object of class Sine */
int OndaSeno::paCallbackMethod(const void *inputBuffer,
	void *outputBuffer,
	unsigned long framesPerBuffer,
	const PaStreamCallbackTimeInfo* timeInfo,
	PaStreamCallbackFlags statusFlags
) {
	float * out = (float *) outputBuffer;

	// Evita advertencias de variable no usada
	(void) timeInfo;
	(void) statusFlags;
	(void) inputBuffer;

	for (unsigned long i = 0; i < framesPerBuffer; i++) {
		*out++ = _sine[_left_phase];  /* izquierda */
		*out++ = _sine[_right_phase];  /* derecha */
		_left_phase += 1;

		if (_left_phase >= TABLE_SIZE) _left_phase -= TABLE_SIZE;

		_right_phase += 3; /* higher pitch so we can distinguish left and right. */

		if (_right_phase >= TABLE_SIZE) _right_phase -= TABLE_SIZE;
	}

	return paContinue;
}

/* This routine will be called by the PortAudio engine when audio is needed.
** It may called at interrupt level on some machines so don't do anything
** that could mess up the system like calling malloc() or free().
*/
int OndaSeno::paCallback( const void *inputBuffer, void *outputBuffer,
	unsigned long framesPerBuffer,
	const PaStreamCallbackTimeInfo* timeInfo,
	PaStreamCallbackFlags statusFlags,
	void *userData
) {
	/* Here we cast userData to OndaSeno* type so we can call the instance method paCallbackMethod, we can do that since
	   we called Pa_OpenStream with 'this' for userData */

	return static_cast<OndaSeno *>(userData)->paCallbackMethod(inputBuffer, outputBuffer,
		framesPerBuffer, timeInfo, statusFlags);
}

void OndaSeno::paStreamFinishedMethod(){
	// Nada que hacer
}

/*
 * Este método se llama por PortAudio al finalizar la reproducción.
 */
void OndaSeno::paStreamFinished(void* userData) {
	return static_cast<OndaSeno*>(userData)->paStreamFinishedMethod();
}
