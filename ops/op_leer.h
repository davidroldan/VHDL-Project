/**
 * @file op_leer.h
 *
 * @brief Operación de lectura y comprobación.
 */

#ifndef OP_LEER_H
#define OP_LEER_H

#include "operacion.h"
#include "nota.h"

namespace ops {

	/**
	 * @brief Operación de lectura y comprobación.
	 */
	class Leer : public Operacion {
	public:
		Leer();

		std::string nombre() const {
			return "leer";
		}

		std::string ayudaBreve() const {
			return "leer archivo\n\t\tInterpreta un archivo FLAN."; 
		}

		std::string ayuda() const {
			return	"Interpreta un archivo FLAN, detecta errores de formato y muestra someras\n"
				"estadísticas de los datos.";
		}

		void iniciar(const std::vector<std::string> &params,
			const std::map<std::string, std::string> &mods) throw (ErrorParametros);

		void ejecutar() throw (Operacion::ErrorEjecucion);

	private:
		bool _detallado;

		std::string _nombreArchivo;

		std::map<NotaMus, std::string> _nombreNota;
	};

}

#endif // OPERACION_H
