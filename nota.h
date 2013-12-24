/**
 * @file nota.h
 *
 * @brief Elemento unitario del un formato de grabación que representa una nota
 * o un comando especial.
 */

#ifndef NOTA_H
#define NOTA_H

#include <iostream>

/**
 * @brief Tipo enumerado para representar las notas de la escala diatónica de
 * Do.
 */
typedef enum {
	SILENCIO, DO, RE, MI, FA, SOL, LA, SI
} NotaMus;

/**
 * @brief Elemento unitario del un formato de grabación que representa una nota
 * o un comando especial.
 */
class Nota {
public:
	/**
	 * @brief Tipo de la nota.
	 */
	enum TipoNota {
		NOTA,
		ESPECIAL
	};

	/**
	 * @brief Indica si la nota leída es un comando especial de final.
	 */
	virtual bool fin() const = 0;

	/**
	 * @brief Devuelve el tipo de nota (en su sentido general) representado.
	 */
	virtual TipoNota tipo() const = 0;

	/**
	 * @brief Nota musical representada.
	 *
	 * @note Sólo tiene sentido cuando tipo() == NOTA.
	 */
	virtual NotaMus nota() = 0;

	/**
	 * @brief Octava de la nota pulsada.
	 *
	 * @note Sólo tiene sentido cuando tipo() == NOTA.
	 */
	virtual unsigned short octava() const = 0;

	/**
	 * @brief Devuelve si la nota tiene sostenido.
	 *
	 * @note Sólo tiene sentido cuando tipo() == NOTA.
	 */
	virtual bool sostenido() const = 0;

	/**
	 * @brief Duración del sonido que representa la nota.
	 *
	 * @note Sólo tiene sentido cuando tipo() == NOTA.
	 */
	virtual float duracion() const = 0;

protected:

	/**
	 * @brief Lee una Nota de un flujo de entrada de texto con el formato
	 * correspondiente.
	 */
	virtual void leeNota(std::istream &in) = 0;

	/**
	 * @brief Escribe una Nota de un flujo de entrada de texto con el formato
	 * correspondiente.
	 */
	virtual void escribeNota(std::ostream &out) const = 0;

	friend std::ostream &operator <<(std::ostream &out, const Nota &nota);

	friend std::istream &operator >>(std::istream &in, Nota & nota);
};

inline std::ostream &operator <<(std::ostream &out, const Nota &nota) {
	nota.escribeNota(out);

	return out;
}

inline std::istream &operator >>(std::istream &in, Nota & nota){
	nota.leeNota(in);

	return in;
}

#endif // NOTA_H
