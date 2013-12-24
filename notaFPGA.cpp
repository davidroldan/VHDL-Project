/**
 * @file notaFPGA.cpp
 *
 * @brief Elemento unitario del formato de grabación de la FPGA que representa
 * una nota musical o un comando especial.
 */

#include <bitset>
#include "notaFPGA.h"

using namespace std;

// Usa unsinged char[2] para evitar consideraciones de "endian"
typedef unsigned char Bloque8;
typedef Bloque8 Bloque16[2];

/**
 * @brief Convierte una nota musical a su codificación
 * empleada en FLAN.
 */
unsigned char denotamus(NotaMus nota){
	switch(nota) {
		case DO : return 1;
		case RE : return 2;
		case MI : return 3;
		case FA : return 4;
		case SOL : return 5;
		case LA : return 6;
		case SI	: return 7;

		case SILENCIO :
		default : return 0;
	}
}

/**
 * @brief Interpreta una codificación de nota como
 * una nota musical.
 */
NotaMus anotamus(unsigned char nota){
	switch(nota) {
		case 1 : return DO;
		case 2 : return RE;
		case 3 : return MI;
		case 4 : return FA;
		case 5 : return SOL;
		case 6 : return LA;
		case 7 : return SI;

		case 0 :
		default : return SILENCIO;
	}
}

////////////////////////////
// Funciones de la clase  //
////////////////////////////

NotaFPGA::NotaFPGA() : _tipo(ESPECIAL) {
}

NotaFPGA::NotaFPGA(NotaMus nota, float duracion, bool sostenido, unsigned short octava)
	: _tipo(NOTA), _nota(nota), _duracion(duracion), _sostenido(sostenido),
		_octava(octava) {
}

bool NotaFPGA::fin() const {
	return (_tipo == ESPECIAL);
}

Nota::TipoNota NotaFPGA::tipo() const {
	return _tipo;
}

NotaMus NotaFPGA::nota(){
	return _nota;
}

unsigned short NotaFPGA::octava() const {
	return _octava;
}

bool NotaFPGA::sostenido() const {
	return _sostenido;
}

float NotaFPGA::duracion() const {
	return _duracion;
}

void NotaFPGA::leeNota(istream &in) {
	Bloque16 bloque;
	Bloque8 marcoNota = 0x70;	// 01110000
	Bloque8 marcoOctava = 0x0E;	// 00001110

	in.read((char *) &bloque, sizeof(Bloque16));

	if (in.fail())
		return;

	// Si es un bloque de nota
	if ((bloque[0] & (1 << 7)) != 0) {
		_tipo = NOTA;

		// Nota
		_nota = anotamus((bloque[0] & marcoNota) >> 4);

		// Octava
		_octava = (bloque[0] & marcoOctava) >> 1;

		// Sostenido
		_sostenido = ((bloque[0] & 1) != 0 ? true : false);

		// Duración
		_duracion = bloque[1];
	}
	else {
		_tipo = ESPECIAL;
	}
}

void NotaFPGA::escribeNota(ostream &out) const {
	Bloque16 bloque = {0, 0};

	if (_tipo == NOTA){
		// Duración
		bloque[1] = (Bloque8) _duracion;

		// Marca de nota
		bloque[0] = (1 << 7);

		// Marca de sostenido
		if (_sostenido)
			bloque[0] |= 1;

		// Nota
		bloque[0] |= denotamus(_nota) << 4;

		// Octava
		bloque[0] |= _octava << 1;
	}
		

	out.write((char *) &bloque, 2);
}
