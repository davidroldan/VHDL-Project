/**
 * @file mflan.cpp
 *
 * @brief Módulo principal del programa.
 */

#include <iostream>
#include <clocale>

using namespace std;

#include "mflan.h"

// Operaciones
#include "ops/op_leer.h"
#include "ops/op_escalar.h"
#include "ops/op_convertir.h"
#ifndef SIN_PORTAUDIO
	#include "ops/op_reproducir.h"
#endif

MFlan::MFlan(int argc, char *argv[]) : _argc(argc), _argv(argv) {

	// Carga las disponibles operaciones en una tabla
	_ops["leer"] = new ops::Leer;
	_ops["escalar"] = new ops::Escalar;
	_ops["convertir"] = new ops::Convertir;

#ifndef SIN_PORTAUDIO
	_ops["reproducir"] = new ops::Reproducir;
#endif
}

MFlan::~MFlan() {
	// Elimina todas las operaciones
	for (map<std::string, Operacion *>::const_iterator it = _ops.begin(); it != _ops.end(); it++)
		delete it->second;
}

int MFlan::ejecutar(){
	cout << "Manipulador de archivos FLAN 1.1" << endl;
	cout << "Equipo1 (" << __DATE__ << ")" << endl << endl;

	setlocale(LC_ALL, "");

	// Procesa la línea de comandos
	try {
		procesarParametros();
	}
	catch (const ExcepcionLineaComandos &e){
		cerr << "Error: " << e.what() << "." << endl << endl;

		imprimirAyuda();

		return 1;
	}

	// Comprueba que existe la operación solicitada (caso especial ayuda)
	if (_nombreOp == "ayuda") {

		imprimirAyudaOperacion();

		return 0;
	}
	else if (_ops.find(_nombreOp) == _ops.end()) {

		cerr << "Error: operación desconocida: " << _nombreOp << "." << endl << endl;

		imprimirAyuda();

		return 2;
	}

	// Ejecuta la operación escogida
	Operacion * operacion = _ops[_nombreOp];

	try {
		operacion->iniciar(_params, _mods);

		operacion->ejecutar();
	}
	catch (const Operacion::ErrorParametros &ep) {
		cerr << "Error: " << ep.what() << "." << endl;

		return 3;
	}
	catch (const Operacion::ErrorEjecucion &ee) {
		cerr << "Error: " << ee.what() << "." << endl;

		return 4;
	}

	return 0;
}

void MFlan::procesarParametros() throw (ExcepcionLineaComandos) {
	if (_argc == 1)
		throw ExcepcionLineaComandos("número insuficiente de parámetros al programa");

	// (1) Lee el nombre de operación
	_nombreOp = _argv[1];

	if (_nombreOp.substr(0, 2) == "--")
		throw ExcepcionLineaComandos("nombre de operación no válido: " + _nombreOp);

	// (2) Lee los modificadores y los parámetros (si los hay)
	int i = 2;

	while (i < _argc) {
		string pal = string(_argv[i]);

		// Si es un modificador
		if (pal.substr(0, 2) == "--") {
			pal = pal.substr(2, string::npos);

			// Si es modificador con valor
			size_t igual = pal.find("=");

			// Comprueba que el modificador no es vacío
			if (pal.substr(0, igual).empty())
				throw ExcepcionLineaComandos("no se admiten modificadores sin nombre");

			if (igual != string::npos)
				_mods[pal.substr(0, igual)] = pal.substr(igual + 1, string::npos);

			else
				_mods[pal] = "";
		}

		// Si es un parámetro
		else {
			_params.push_back(pal);
		}

		// Aumenta el índice
		i++;
	}
}

void MFlan::imprimirAyuda() const {
	cout << "Sintaxis del comando: mflan operacion [modificadores] <parametros>: " << endl;

	for (map<std::string, Operacion *>::const_iterator it = _ops.begin(); it != _ops.end(); it++) {
		cout << "\t" << it->second->ayudaBreve() << endl;
	}

	if (_ops.empty())
		cout << "\tNo hay operaciones disponibles." << endl;
	else
		cout << "\tayuda operacion\n\t\tMuestra ayuda sobre una operación." << endl;
}

void MFlan::imprimirAyudaOperacion() const {

	// Si los parámetros no son correctos o se pide ayuda de la propia ayuda
	if (!_mods.empty() || _params.size() != 1 || _params.front() == "ayuda")
		cerr << "La sintaxis para el comando de ayuda es: ayuda <nombre operación>." << endl;

	else {
		// Obtiene el nombre de operación para el que se pide ayuda
		string nop = _params.front();

		// Se busca entre las disponibles
		map<std::string, Operacion *>::const_iterator oper = _ops.find(nop);

		if (oper == _ops.end())
			cerr << "Error: operación \'" << nop << "\' desconocida." << endl;

		else
			cout << "Ayuda para \'" << nop << "\':" << endl << oper->second->ayuda() << endl;
	}
}
