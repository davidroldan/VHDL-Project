/**
 * @file op_convertir.cpp
 *
 * @brief Operación de conversión de formato legible a FLAN.
 *
 */

#include <cstring>
#include <cstdlib>
#include <string>
#include <fstream>
#include <cerrno>

#include "op_convertir.h"

#include "notaFPGA.h"
#include "lylector.h"

using namespace std;
using namespace ops;

Convertir::Convertir() {
}

void Convertir::iniciar(const vector<string> &params, const map<string, string> &mods) throw (ErrorParametros) {
	// Procesa los parámetros
	if (params.size() > 2)
		throw ErrorParametros("demasiados parámetros para la operación");

	else if (params.size() < 2)
		throw ErrorParametros("parámetros insuficientes para la operación");

	else {

		// Lee el archivo de origen
		_nOrigen = params[0];

		// Lee el archivo de destino si existe
		_nDestino = params[1];

		// Comprueba (sin demasiada intención) que no es el origen
		if (_nOrigen == _nDestino)
			throw ErrorParametros("el archivo de origen y destino no pueden coincidir");
	}

	// El comando no acepta modificadores
	if (!mods.empty()) {
		throw ErrorParametros("la operación \'convertir\' no admite modificadores.");
	}
}

void Convertir::ejecutar() throw (ErrorEjecucion) {
	// (*) Archivo de lectura
	ifstream origen;

	// Intenta abrir el archivo
	origen.open(_nOrigen.c_str());

	if (!origen.is_open())
		throw ErrorEjecucion("no se pudo abrir el archivo origen: " + string(strerror(errno)));

	// Utiliza el LyLector
	LyLector lector(origen);

	// Intenta leer la parte inicial
	try {
		lector.iniciar();
	}
	catch (LyLector::ErrorFormato &ef) {
		throw ErrorEjecucion(_nOrigen + ":" + ef.what());
	}

	// Archivo de escritura
	ofstream destino;

	destino.open(_nDestino.c_str(), ios::binary);

	if (!destino.is_open())
		throw ErrorEjecucion("no se pudo abrir el archivo destino: " + string(strerror(errno)));

	// Variables necesarias durante el proceso
	NotaFPGA nota, notant;
	unsigned int nbloques = 0;

	try {
		nota = lector.getNota();	

		while (!lector.fin()) {
			destino << nota;
			nbloques++;		

			notant = nota;
			nota = lector.getNota();

			// Añade un espacio entre notas iguales no ligadas
			if (!lector.fin() && nota.nota() == notant.nota() && nota.octava() == notant.octava()
				&& nota.sostenido() == notant.sostenido() && !lector.estaLigada())

				destino << NotaFPGA(SILENCIO, 1, false, nota.octava());
		}
	}
	catch (LyLector::ErrorFormato &ef) {
		throw ErrorEjecucion(_nOrigen + ":" + ef.what());
	}

	// Pone la marca de fin
	destino << NotaFPGA();

	// Cierra los archivos
	origen.close();
	destino.close();
}
