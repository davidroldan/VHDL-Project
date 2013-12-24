/**
 * @file op_reproducir.h
 *
 * @brief Operación de reproducción.
 */

#ifndef OP_REPRODUCIR_H
#define OP_REPRODUCIR_H

#include "operacion.h"
#include "nota.h"

namespace ops {

	/**
	 * @brief Operación de reproducción.
	 */
	class Reproducir : public Operacion {
	public:
		std::string nombre() const {
			return "reproducir";
		}

		std::string ayudaBreve() const {
			return "reproducir archivo\n\t\tReproduce un archivo FLAN."; 
		}

		std::string ayuda() const {
			return	"Reproduce un archivo FLAN.";
		}

		void iniciar(const std::vector<std::string> &params,
			const std::map<std::string, std::string> &mods) throw (ErrorParametros);

		void ejecutar() throw (Operacion::ErrorEjecucion);

	private:
		std::string _nombreArchivo;
	};

}

#endif // OP_REPRODUCIR_H
