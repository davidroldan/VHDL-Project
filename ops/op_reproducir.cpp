/**
 * @file op_reproducir.cpp
 *
 * @brief Operación de reproducción.
 *
 */

#include <cstring>
#include <string>
#include <limits>
#include <fstream>
#include <cerrno>
#include <cmath>

#include "op_reproducir.h"

#include <portaudiocpp/PortAudioCpp.hxx>

#include "ondaseno.h"

#include "notaFPGA.h"

using namespace std;
using namespace ops;

unsigned int frecuenciaNota(NotaMus nota, int octava, bool sos){
	int notast;

	// Convierte la nota
	switch (nota) {
		case DO : notast = 1; break;
		case RE : notast = 3; break;
		case MI : notast = 5; break;
		case FA : notast = 6; break;
		case SOL : notast = 8; break;
		case LA : notast = 10; break;
		case SI : notast = 12; break;
		default : notast = 0;
	}
	
	// Añade un semitono con el sostenido
	if (sos) notast++;
	
	return 440 * pow(1.059463094359295, ((octava+1)-4) * 12 + (notast - 10)) * 100;
}

void Reproducir::iniciar(const std::vector<std::string> &params, const std::map<std::string, std::string> &mods) throw (ErrorParametros) {
	// Procesa el parámetro
	if (params.size() > 1)
		throw ErrorParametros("demasiados parámetros para la operación");

	else if (params.size() < 1)
		throw ErrorParametros("nombre del archivo ausente");

	else
		_nombreArchivo = params.front();


	// El comando no acepta modificadores
	if (!mods.empty()) {
		throw ErrorParametros("la operación \'reproducir\' no admite modificadores.");
	}
}

void Reproducir::ejecutar() throw (ErrorEjecucion) {
	// Archivo de lectura
	ifstream arch;

	// Intenta abrir el archivo
	arch.open(_nombreArchivo.c_str(), ios::binary);

	if (!arch.is_open())
		throw ErrorEjecucion("no se pudo abrir el archivo: " + string(strerror(errno)));


	// (*) Inicia PortAudio
	try {
		// Crea el sistema
		portaudio::AutoSystem autoSis;
		portaudio::System &sis = portaudio::System::instance();

		// Parámetros de salida
		portaudio::DirectionSpecificStreamParameters outParams (
			sis.defaultOutputDevice(),
			2,				// salida estéreo
			portaudio::FLOAT32,
			false,
			sis.defaultOutputDevice().defaultLowOutputLatency(),
			NULL
		);

		// Constantes de la configuración
		const unsigned int FRAMES_PER_BUFFER = 64;
		const double SAMPLE_RATE = 44100.0;

		// Parámetros generales (sólo salida)
		portaudio::StreamParameters params (
			portaudio::DirectionSpecificStreamParameters::null(),
			outParams,
			SAMPLE_RATE,
			FRAMES_PER_BUFFER,
			paClipOff
		);

		// Crea el objeto de onda seno
		OndaSeno onda;

		// Crea la el flujo
		portaudio::MemFunCallbackStream<OndaSeno> stream(params, onda, &OndaSeno::generate);

		// Variable necesarias durante el proceso
		NotaFPGA nota;

		arch >> nota;

		stream.start();

		while (!arch.eof() && !nota.fin()) {

			// Distingue silencio de nota audible 
			if (nota.nota() != SILENCIO)
				onda.fijarFrecuencia(numeric_limits<float>::infinity());
			else
				onda.fijarFrecuencia(frecuenciaNota(nota.nota(), nota.octava(), nota.sostenido()));

				sis.sleep(nota.duracion() * 167.7722);
				sis.sleep(nota.duracion() * 167.7722);

			arch >> nota;
		}

		// Cierra PortAudio
		stream.stop();
		stream.close();
		sis.terminate();

		// Comprueba si ha acabado el archivo o si ha habido señal de fin
		arch >> nota;

		if (!arch.eof())
			cerr << "Aviso: el archivo continúa tras el fin de los datos." << endl;
		else if (!nota.fin())
			cerr << "Error: el archivo acaba sin presentar señal de terminación." << endl;

		// Cierra archivos y demás
		arch.close();
	}
	catch (const portaudio::PaException &e) {
		throw ErrorEjecucion("error de sonido: " + string(e.paErrorText()));
	}
	catch (const portaudio::PaCppException &e) {
		throw ErrorEjecucion("error de sonido: " + string(e.what()));
	}
}
