/**
 * @file lylector.h
 *
 * @brief Lector de partituras en un formato similar a Lilypond.
 */

#ifndef LYLECTOR_H
#define LYLECTOR_H

#include <iostream>
#include <stdexcept>

#include "notaFPGA.h"

/**
 * @brief Clase lectora de un formato humanamente legible de partituras.
 */
class LyLector {
public:
	/**
	 * @brief Excepción por error de formato
	 */
	class ErrorFormato : public std::runtime_error {
	public:
		explicit ErrorFormato(const std::string &what);

		explicit ErrorFormato(int fila, int col, const std::string &what);
	};

	/**
	 * @brief Genera un LyLector para el flujo de entrada dado.
	 *
	 * @param Flujo de entrada (LyLector no se responsabiliza de él)
	 */
	LyLector(std::istream &in);

	/**
	 * @brief Inicia el lector, leyendo los encabezados...
	 */
	void iniciar() throw (ErrorFormato);


	/**
	 * @brief Lee una nota.
	 *
	 * @note Esta función no se ha de llamar antes de iniciar.
	 * @return La nota leído o una nota especial de final si se
	 * ha llegado al fin del archivo.
	 */
	NotaFPGA getNota() throw (ErrorFormato);

	/**
	 * @brief Comprueba si se ha llegado al fin del archivo.
	 */
	bool fin() const;
	
	
private:
	/// Omite los blancos
	void omitirBlancos();
	/// Lee una palabra
	std::string leerPalabra();
	/// Lee un número
	int leerNumero() throw (ErrorFormato);
	/// Lee el siguiente carácter modificando
	/// el estado en consecuencia
	void sigCaracter();
	// Marca la posición actual para mensajes de error
	void marcarPosicion();
	/// Lee una nota
	void leerNota() throw (ErrorFormato);
	/// Lee la nota inicial (marca relativa)
	void leerNotaInicial() throw (ErrorFormato);

	/// Fuente de datos
	std::istream &_fuente;
	
	/// Línea actual
	int _linea;
	
	/// Columna
	int _col;

	/// Carácter actual
	char _ccar;

	/// Última posición con sentido (para notificación de errores)
	int _elinea, _ecol;

	/// Fin del archivo
	bool _eof;

	/// Tempo
	int _tempo;

	/// Nota leída
	int _nota;

	/// Octava
	int _octava;

	// Duración
	int _duracion;

	/// Silencio?
	bool _silencio;
};

#endif // LYLECTOR_H
