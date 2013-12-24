/**
 * @file op_escalar.h
 *
 * @brief Operación de escalado de duración para archivos FLAN.
 */

#ifndef OP_ESCALAR_H
#define OP_ESCALAR_H

#include "operacion.h"
#include "nota.h"

namespace ops {

	/**
	 * @brief Operación de escalado de duración para archivos FLAN.
	 */
	class Escalar : public Operacion {
	public:
		Escalar();

		std::string nombre() const {
			return "escalar";
		}

		std::string ayudaBreve() const {
			return "escalar factor origen [destino]\n\t\tEscala la duración de un archivo FLAN."; 
		}

		std::string ayuda() const {
			return	"Multiplica la duración de las notas de un archivo FLAN, detectando errores\n"
				"por desbordamiento o truncamiento. El factor ha de ser mayor que 0. Si no\n"
				"se indica el archivo de destino se sobrescribirá el original.";
		}

		void iniciar(const std::vector<std::string> &params,
			const std::map<std::string, std::string> &mods) throw (ErrorParametros);

		void ejecutar() throw (Operacion::ErrorEjecucion);

	private:
		/// Factor de escala
		float _factor;
		/// Nombre del archivo de origen
		std::string _nOrigen;
		/// Nombre del archivo de destino
		std::string _nDestino;
	};

}

#endif // OP_ESCALAR_H
