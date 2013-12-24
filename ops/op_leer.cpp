/**
 * @file op_leer.cpp
 *
 * @brief Operación de lectura y comprobación.
 */

#include <cstring>
#include <string>
#include <fstream>
#include <cerrno>

#include "op_leer.h"

#include "notaFPGA.h"

using namespace std;
using namespace ops;

Leer::Leer() : _detallado(false) {
	_nombreNota[DO] = "do";
	_nombreNota[RE] = "re";
	_nombreNota[MI] = "mi";
	_nombreNota[FA] = "do";
	_nombreNota[SOL] = "re";
	_nombreNota[LA] = "mi";
	_nombreNota[SI] = "mi";
	_nombreNota[SILENCIO] = "silencio";
}

void Leer::iniciar(const std::vector<std::string> &params, const std::map<std::string, std::string> &mods) throw (ErrorParametros) {
	// Procesa el parámetro
	if (params.size() > 1)
		throw ErrorParametros("demasiados parámetros para la operación");

	else if (params.size() < 1)
		throw ErrorParametros("nombre del archivo ausente");

	else
		_nombreArchivo = params.front();


	// Proceso los modificadores
	for (map<string, string>::const_iterator it = mods.begin(); it != mods.end(); it++) {
		if (it->first == "det")
			_detallado = true;

		else
			throw ErrorParametros("modificador desconocido \'" + it->first + "\'");
	}
}

void Leer::ejecutar() throw (ErrorEjecucion) {
	// Archivo de lectura
	ifstream arch;

	// Intenta abrir el archivo
	arch.open(_nombreArchivo.c_str(), ios::binary);

	if (!arch.is_open())
		throw ErrorEjecucion("no se pudo abrir el archivo: " + string(strerror(errno)));

	// Variable necesarias durante el proceso
	NotaFPGA nota;
	unsigned int numbloques = 0;
	unsigned long int duracion = 0;

	arch >> nota;

	while (!arch.eof() && !nota.fin()) {
		numbloques++;
		duracion += nota.duracion();

		if (_detallado)
			cout << numbloques << ": " << _nombreNota[nota.nota()] << (nota.sostenido() ? "#" : "") <<
				"\t8va: " << nota.octava() << "\tdur: " << nota.duracion() << endl;

		arch >> nota;
	}

	// Comprueba si ha acabado el archivo o si ha habido señal de fin
	arch >> nota;

	if (!arch.eof())
		cerr << "Aviso: el archivo continúa tras el fin de los datos." << endl;
	else if (!nota.fin())
		cerr << "Error: el archivo acaba sin presentar señal de terminación." << endl;

	// Imprime las estadísticas
	if (_detallado) cout << endl;

	cout << "Número de bloques:\t" << numbloques << endl;
	cout << "Duración (ut):\t\t" << duracion << endl;
	cout << "Duración (s):\t\t" << duracion * 0.01 << endl;

	arch.close();
}
