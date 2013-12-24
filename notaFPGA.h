/**
 * @file notaFPGA.h
 *
 * @brief Elemento unitario del formato de grabación de la FPGA que representa
 * una nota musical o un comando especial.
 */

#ifndef NOTA_FPGA_H
#define NOTA_FPGA_H

#include <iostream>

#include "nota.h"

/**
 * @brief Elemento unitario del un formato de grabación que representa una nota
 * o un comando especial.
 */
class NotaFPGA : public Nota {
public:

	/**
	 * @brief Crea una nota especial de fin.
	 */
	NotaFPGA();

	/**
	 * @brief Crea una nota musical.
	 */
	NotaFPGA(NotaMus nota, float duracion, bool sostenido = true, unsigned short octava = 4);

	/**
	 * @brief Indica si la nota leída es un comando especial de final.
	 */
	bool fin() const;

	/**
	 * @brief Devuelve el tipo de nota (en su sentido general) representado.
	 */
	TipoNota tipo() const;

	/**
	 * @brief Nota musical representada.
	 *
	 * @note Sólo tiene sentido cuando tipo() == NOTA.
	 */
	NotaMus nota();

	/**
	 * @brief Octava de la nota pulsada.
	 *
	 * @note Sólo tiene sentido cuando tipo() == NOTA.
	 */
	unsigned short octava() const;

	/**
	 * @brief Devuelve si la nota tiene sostenido.
	 *
	 * @note Sólo tiene sentido cuando tipo() == NOTA.
	 */
	bool sostenido() const;

	/**
	 * @brief Duración del sonido que representa la nota.
	 *
	 * @note Sólo tiene sentido cuando tipo() == NOTA.
	 */
	float duracion() const;

protected:
	/**
	 * @brief Lee una Nota de un flujo de entrada de texto con el formato
	 * correspondiente.
	 */
	void leeNota(std::istream &in);

	/**
	 * @brief Escribe una Nota de un flujo de entrada de texto con el formato
	 * correspondiente.
	 */
	void escribeNota(std::ostream &out) const;

private:
	/// Tipo de la nota (en sentido general)
	TipoNota _tipo;

	/// Nota musical
	NotaMus _nota;
	/// Duración
	float _duracion;
	/// Sostenido
	bool _sostenido;
	/// Octava
	unsigned short _octava;
};

#endif // NOTA_FPGA_H
