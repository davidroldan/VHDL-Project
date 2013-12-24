/**
 * @file op_escalar.cpp
 *
 * @brief Operación de escalado de duración para archivos FLAN.
 *
 */

#include <cstring>
#include <cstdlib>
#include <string>
#include <fstream>
#include <cerrno>

#include "op_escalar.h"

#include "notaFPGA.h"

using namespace std;
using namespace ops;

Escalar::Escalar() : _factor(1), _nDestino("") {
}

void Escalar::iniciar(const std::vector<std::string> &params, const std::map<std::string, std::string> &mods) throw (ErrorParametros) {
	// Procesa los parámetros
	if (params.size() > 3)
		throw ErrorParametros("demasiados parámetros para la operación");

	else if (params.size() < 2)
		throw ErrorParametros("parámetros insuficientes para la operación");

	else {
		// Lee el factor
		_factor = atof(params.front().c_str());

		if (_factor <= 0)
			throw ErrorParametros(string("el factor introducido \'") + params.front() + "\' no es número positivo");

		// Lee el archivo de origen
		_nOrigen = params[1];

		// Lee el archivo de destino si existe
		if (params.size() == 3)
			_nDestino = params.back();

		// Comprueba (sin demasiada intención) que no es el origen
		if (_nOrigen == _nDestino)
			throw ErrorParametros("el archivo de origen y destino no pueden coincidir");
	}

	// El comando no acepta modificadores
	if (!mods.empty()) {
		throw ErrorParametros("la operación \'escalar\' no admite modificadores.");
	}
}

void Escalar::ejecutar() throw (ErrorEjecucion) {
	// Variable para nombre de archivo temporal (si hace falta)
	const char * temporal = NULL;

	// Archivo de lectura
	ifstream origen;

	// Intenta abrir el archivo
	origen.open(_nOrigen.c_str(), ios::binary);

	if (!origen.is_open())
		throw ErrorEjecucion("no se pudo abrir el archivo origen: " + string(strerror(errno)));


	// Archivo de escritura
	ofstream destino;

	if (_nDestino != "")
		destino.open(_nDestino.c_str(), ios::binary);
	else {
		// El probable que el compilador se queje de la peligrosidad de 'tmpnam'
		temporal = tmpnam(NULL);

		if (temporal == NULL)
			throw ErrorEjecucion("no se pudo generar un archivo temporal");

		destino.open(temporal, ios::binary);
	}

	if (!destino.is_open()) {
		if (_nDestino != "")
			throw ErrorEjecucion("no se pudo abrir el archivo destino: " + string(strerror(errno)));

		else
			throw ErrorEjecucion("no se pudo abrir el archivo temporal");
	}

	// Variables necesarias durante el proceso
	NotaFPGA nota;
	unsigned int nbloque = 0;
	float duracion = 0;

	origen >> nota;

	while (!origen.eof() && !nota.fin()) {
		// Multiplica la duración por el factor
		duracion = nota.duracion() * _factor;

		// Si la duración excede el máximo representable pone el máximo
		if (duracion > 255) {
			cerr << "Atención: la nueva duración excede el tamaño de representación del formato. "
				"Su valor será truncado (bloque " << nbloque << ")." << endl;

			duracion = 255;
		}
		else if ((unsigned char)(duracion) == 0) {
			cerr << "Atención: la nueva duración no llega al mínimo representable del formato. "
				"La nota será eliminada (bloque " << nbloque << ")." << endl;
		}
		
		if ((unsigned char)(duracion) != 0) {
			nota = NotaFPGA(nota.nota(), duracion, nota.sostenido(), nota.octava());
			
			destino << nota;
		}

		nbloque++;
		origen >> nota;
	}

	// Comprueba si ha acabado el archivo o si ha habido señal de fin
	origen >> nota;

	if (!origen.eof())
		cerr << "Aviso: el archivo continúa tras el fin de los datos." << endl;
	else if (!nota.fin())
		cerr << "Error: el archivo acaba sin presentar señal de terminación. Esta anomalia"
			"se subsanará en el archivo destino." << endl;

	// Pone la marca de fin
	destino << NotaFPGA();

	// Cierra los archivos
	origen.close();
	destino.close();

	// Si había que sobrescribir, sobrescribe
	if (_nDestino == "")
		if (rename(temporal, _nOrigen.c_str()) != 0)
			throw ErrorEjecucion("no se pudo copiar el archivo temporal para sobrescribir el archivo de origen");
}
