/**
 * @file mflan.h
 *
 * @brief Módulo principal del programa.
 */

#ifndef MFLAN_H
#define MFLAN_H

#include <map>
#include <vector>
#include <string>
#include <stdexcept>

#include "operacion.h"

/**
 * @brief Clase principal del programa.
 */
class MFlan {
public:

	/**
	 * @brief Construye la aplicación MFlan.
	 *
	 * @param argc Número de parámetros de línea de comandos.
	 * @param argv Parámetros de la línea de comandos.
	 */
	MFlan(int argc, char *argv[]);

	/**
	 * @brief Destruye la aplicación MFlan.
	 */
	~MFlan();

	/**
	 * @brief Ejecuta la aplicación MFlan.
	 */
	int ejecutar();

private:
	/// Excepción al procesar la línea de comandos.
	class ExcepcionLineaComandos : public std::runtime_error {
	public:
		ExcepcionLineaComandos(const std::string &what)
			: std::runtime_error(what) {};

		using std::runtime_error::what;
	};

	/// Procesa la línea de comandos.
	void procesarParametros() throw (ExcepcionLineaComandos);

	/// Imprimir ayuda
	void imprimirAyuda() const;
	/// Imprimir ayuda de la operación
	void imprimirAyudaOperacion() const;

	// Variables auxiliares
	int _argc;
	char ** _argv;
	
	/// Nombre de la operación activa
	std::string _nombreOp;
	/// Modificadores leídos de la lc
	std::map<std::string, std::string> _mods;
	/// Parámetros leídos de la lc
	std::vector<std::string> _params;
	/// Tabla de operaciones conocidas
	std::map<std::string, Operacion *> _ops;

};

#endif // MFLAN_H
