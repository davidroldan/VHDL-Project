/**
 * @file op_convertir.h
 *
 * @brief Operación de conversión de formato legible a FLAN.
 *
 */

#ifndef OP_CONVERTIR_H
#define OP_CONVERTIR_H

#include "operacion.h"
#include "nota.h"

namespace ops {

	/**
	 * @brief Operación de conversión de formato legible a FLAN.
	 */
	class Convertir : public Operacion {
	public:
		Convertir();

		std::string nombre() const {
			return "convertir";
		}

		std::string ayudaBreve() const {
			return "convertir origen destino\n\t\tConvierte un archivo legible al formato FLAN."; 
		}

		std::string ayuda() const {
			return	"Convierte un archivo legible al formato FLAN. El formato de entrada está\n"
				"basado en el formato del programa Lilypond.";
		}

		void iniciar(const std::vector<std::string> &params,
			const std::map<std::string, std::string> &mods) throw (ErrorParametros);

		void ejecutar() throw (Operacion::ErrorEjecucion);

	private:
		/// Nombre del archivo de origen
		std::string _nOrigen;
		/// Nombre del archivo de destino
		std::string _nDestino;
	};

}

#endif // OP_CONVERTIR_H
