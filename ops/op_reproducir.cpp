/**
 * @file op_reproducir.cpp
 *
 * @brief Operación de reproducción.
 *
 * @todo No se hace la multiplicación para las escalas.
 */

#include <cstring>
#include <fstream>
#include <cerrno>

#include "op_reproducir.h"

#include "ondaseno.h"

#include "notaFPGA.h"

using namespace std;
using namespace ops;

unsigned int frecuenciaNota(NotaMus nota){
	switch (nota) {
		case DO : return 26163;
		case RE : return 29366;
		case MI : return 32963;
		case FA : return 34923;
		case SOL : return 39200;
		case LA : return 44000;
		case SI : return 49388;
		default	: return 0;
	}
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
		throw ErrorParametros("la operación \'escalar\' no admite modificadores.");
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
	PaError err;

	err = Pa_Initialize();

	if (err != paNoError) {
		Pa_Terminate();

		throw ErrorEjecucion("error de sonido: " + string(Pa_GetErrorText(err)));
	}

	// Variable necesarias durante el proceso
	NotaFPGA nota;
	OndaSeno onda;

	arch >> nota;

	while (!arch.eof() && !nota.fin()) {

		// Distingue silencio de nota audible 
		if (nota.nota() != SILENCIO) {
			onda = OndaSeno(frecuenciaNota(nota.nota()) * 1 << (nota.octava() - 3));

			onda.open(Pa_GetDefaultOutputDevice());

			if (onda.start()) {
				Pa_Sleep(nota.duracion() * 40);
				onda.stop();
			}

			onda.close();
		}
		else
			Pa_Sleep(nota.duracion() * 40);

		arch >> nota;
	}

	// Comprueba si ha acabado el archivo o si ha habido señal de fin
	arch >> nota;

	if (!arch.eof())
		cerr << "Aviso: el archivo continúa tras el fin de los datos." << endl;
	else if (!nota.fin())
		cerr << "Error: el archivo acaba sin presentar señal de terminación." << endl;

	// Cierra archivos y demás
	arch.close();

	Pa_Terminate();
}
