/**
 * @file operacion.h
 *
 * @brief Operación genérica.
 */

#ifndef OPERACION_H
#define OPERACION_H

#include <iostream>
#include <map>
#include <vector>

#include <stdexcept>

/**
 * @brief Operación genérica.
 */
class Operacion {
public:
	/**
	 * @brief Excepción provocada por algún problema en los
	 * parámetros aportados.
	 */
	class ErrorParametros : public std::runtime_error {
	public:
		ErrorParametros(const std::string &what)
			: std::runtime_error(what) {};

		using std::runtime_error::what;
	};

	/**
	 * @brief Error provocado durante la ejecución de la
	 * operación.
	 */
	class ErrorEjecucion : public std::runtime_error {
	public:
		ErrorEjecucion(const std::string &what)
			: std::runtime_error(what) {};

		using std::runtime_error::what;
	};

	/**
	 * @brief Nombre de la operación.
	 */
	virtual std::string nombre() const = 0;

	/**
	 * @brief Ayuda breve o perfil de la operación.
	 */
	virtual std::string ayudaBreve() const = 0;

	/**
	 * @brief Ayuda extendida de la operación.
	 */
	virtual std::string ayuda() const = 0;

	/**
	 * @brief Inicia y configura la operación.
	 *
	 * @param params parámetros de la operación.
	 * @param mods modificadores de la operación.
	 */
	virtual void iniciar(const std::vector<std::string> &params,
		const std::map<std::string, std::string> &mods) throw (ErrorParametros) = 0;

	/**
	 * @brief Ejecuta la operación.
	 */
	virtual void ejecutar() throw (ErrorEjecucion) = 0;

	/**
	 * @brief Destructor virtual.
	 */
	virtual ~Operacion() {};
};

#endif // OPERACION_H
