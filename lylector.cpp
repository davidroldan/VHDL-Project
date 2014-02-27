/**
 * @file lylector.cpp
 *
 * @brief Lector de partituras en un formato similar a Lilypond.
 *
 * @note Usa las funciones to_string de <string> de C++11.
 */

#include <limits>
#include <string>
#include <cstdlib>
#include <cctype>

#include "lylector.h"

#include "notaFPGA.h"

using namespace std;

// Factor de duración de las unidades de tiempo del formato
const double FACTOR_DURACION = (4096.0 / 390625) * 1000; // milisegundos

/**
 * @brief Convierte de la representación interna para las notas
 * (por semitonos) a NotaMus.
 */
NotaMus convNota(int nota){
	switch (nota){
		case 0 :
		case 1 :
			return DO;
		case 2 :
		case 3 :
			return RE;
		case 4 :
			return MI;
		case 5 :
		case 6 :
			return FA;
		case 7 :
		case 8 :
			return SOL;
		case 9 :
		case 10	:
			return LA;
		case 11	:
			return SI;

		default :
			return SILENCIO;
	}
}

/**
 * @brief Obtiene si la nota tiene sostenido o no a partir
 * de la representación interna.
 */
bool convSostenido(int nota) {
	switch (nota) {
		case 1 :
		case 3 :
		case 6 :
		case 8 :
		case 10 :
			return true;
		default :
			return false;
	}
}

LyLector::LyLector(istream &in) : _fuente(in), _linea(1), _col(0), _ccar(' '), _eof(false), _tempo(60), _octava(1), _ligada(false) { }


void LyLector::iniciar() throw (ErrorFormato) {
	// Se salta lo que haya que saltarse
	omitirBlancos();

	while (_ccar == '\\') {
		string comando = leerPalabra();

		if (comando == "\\tempo") {
			_tempo = leerNumero();

			if (_tempo <= 0)
				throw ErrorFormato(_elinea, _ecol, string("el tempo no puede ser negativo"));
		}
		else if (comando == "\\relative") {
			leerNotaInicial();
		}
		else
			throw ErrorFormato(_elinea, _ecol, "comando desconocido \'" +
				comando.substr(1, string::npos) + "\'");

		omitirBlancos();
	}

	// A partir de ahora se pueden leer notas
}

NotaFPGA LyLector::getNota() throw (ErrorFormato) {
	// Lee las notas en las variables internas
	leerNota();

	// Si se ha acabado el archivo devuelve una nota especial de final
	if (_eof)
		return NotaFPGA();

	if (!_silencio)
		return NotaFPGA(convNota(_nota), _duracion, convSostenido(_nota), _octava);
	else
		return NotaFPGA(SILENCIO, _duracion, false, 0);
}

void LyLector::leerNota() throw (ErrorFormato) {
	string snota = leerPalabra();

	// Abre un bloque de notas ligadas
	if (snota == "(") {
		_ligada = true;
		
		snota = leerPalabra();
	}

	// Cierra un bloque de notas ligadas
	if (snota == ")") {
		_ligada = false;

		snota = leerPalabra();
	}

	// Si es una barra de compás la omite
	if (snota == "|")
		snota = leerPalabra();

	if (snota == "|")
		throw ErrorFormato(_elinea, _ecol, "encontradas dos barras de compás seguidas");

	// Abandona si se ha acabado el archivo
	if (_eof)
		return;

	// Valores auxiliares
	_silencio = false;
	int difnota = _nota;

	// (1) Extrae la nota
	switch (tolower(snota[0])) {
		case 'a' : _nota = 9;	break;
		case 'b' : _nota = 11;	break;
		case 'c' : _nota = 0;	break;
		case 'd' : _nota = 2;	break;
		case 'e' : _nota = 4;	break;
		case 'f' : _nota = 5;	break;
		case 'g' : _nota = 7;	break;

		case 'r' : _silencio = true; break; 

		default:
			throw ErrorFormato(_elinea, _ecol, string("\'") + snota[0] + "\' no es un nombre de nota conocido");
	}

	// Ajusta a la nota más cercana
	if (!_silencio) {
		difnota = difnota - _nota;

		if (difnota > 6)
			_octava++;
		else if (difnota < -6)
			_octava--;
	}

	snota = snota.substr(1, string::npos);

	if (snota.empty())
		throw ErrorFormato(_elinea, _ecol, "se esperaba un indicador de duración");

	// (2) Procesa el sostenido	
	if (!_silencio && (snota[0] == 'e' || snota[0] == 'i')) {

		if (snota.length() < 2 || snota[1] != 's')
			throw ErrorFormato(_elinea, _ecol, "se esperada una alteración");

		// Despreocupación: las alteraciones no cambian la octava si# será el do de abajo

		if (snota[0] == 'e')
			_nota = (_nota - 1) % 12;
		else
			_nota = (_nota + 1) % 12;

		snota = snota.substr(2, string::npos);

	
		if (snota.empty())
			throw ErrorFormato(_elinea, _ecol, "se esperaba un indicador de duración");
	}

	// (3) Se ocupa de cambios de octava
	if (!_silencio && (snota[0] == ',' || snota[0] == '\'')) {
		unsigned int i = 0;

		while (i < snota.length()) {
			if (snota[i] == ',')
				_octava--;

			else if (snota[i] == '\'')
				_octava++;
			else
				break;

			i++;
		}

		if (_octava < 0 || _octava > 7)
			throw ErrorFormato(_elinea, _ecol, "la octava de la nota introducida no está en el rango esperado");

		snota = snota.substr(i, string::npos);

		if (snota.empty())
			throw ErrorFormato(_elinea, _ecol, "se esperaba un indicador de duración");
	}

	// (4) Atiende al indicador de duración
	_duracion = atoi(snota.c_str());

	if (_duracion != 1 && _duracion != 2 && _duracion != 4 && _duracion != 8 && _duracion != 16 && _duracion != 32)
		throw ErrorFormato(_elinea, _ecol, "indicador de duración no soportado");

	_duracion = ((((1000.0 / FACTOR_DURACION) * 60) / _tempo) * 4) / _duracion;

	// Aplica el puntillo
	if (snota[snota.length()-1] == '.')
		_duracion *= 1.5;

	// Negligencia consentida: puede haber basura entre el número y el puntillo o el final
}

void LyLector::leerNotaInicial() throw (ErrorFormato) {
	string snota = leerPalabra();

	// (1) Extrae la nota
	switch (tolower(snota[0])) {
		case 'a' : _nota = 9;	break;
		case 'b' : _nota = 11;	break;
		case 'c' : _nota = 0;	break;
		case 'd' : _nota = 2;	break;
		case 'e' : _nota = 4;	break;
		case 'f' : _nota = 5;	break;
		case 'g' : _nota = 7;	break;

		case 'r' :
			throw ErrorFormato (_elinea, _ecol, "en este contexto no tiene sentido un silencio");

		default:
			throw ErrorFormato(_elinea, _ecol, string("\'") + snota[0] + "\' no es un nombre de nota conocido");
	}

	snota = snota.substr(1, string::npos);

	// (2) Mueve las octavas
	unsigned int i = 0;

	while (i < snota.length()) {
		if (snota[i] == ',')
			_octava--;

		else if (snota[i] == '\'')
			_octava++;
		else
			break;

		i++;
	}

	if (_octava < 0 || _octava > 7)
		throw ErrorFormato(_elinea, _ecol, "la octava inicial introducida no está en el rango esperado");

	if (!snota.substr(i, string::npos).empty())
		throw ErrorFormato(_elinea, _ecol, "carácteres inesperados en la secuencia");
}

inline bool esBlanco(char c){
	return c == ' ' || c == '\t' || c == '\n' || c == '\r';
}

void LyLector::omitirBlancos() {
	// Omite espacios, tabulaciones, saltos de línea y retornos de carro
	while (esBlanco(_ccar) && !_eof) {
		sigCaracter();

		// Se traga también los comentarios, que comienzan por '%'
		while (_ccar == '%') {
			_fuente.ignore(numeric_limits<streamsize>::max(), '\n');

			_linea++;
			_col = 0;

			sigCaracter();
		}
	}
}

string LyLector::leerPalabra() {
	string str;

	omitirBlancos();

	// Marca la posición (para mejorar la notificación de errores)
	marcarPosicion();

	while (!esBlanco(_ccar) && !_eof){
		str.push_back(_ccar);
		sigCaracter();
	}

	return str;
}

int LyLector::leerNumero() throw (ErrorFormato) {
	int num = atoi(leerPalabra().c_str());

	if (num == 0)
		throw ErrorFormato(_elinea, _ecol, "no se pudo interpretar como un número no nulo");

	return num;
}

void LyLector::sigCaracter() {
	int c = _fuente.get();

	// Comprueba si se ha alcanzado el final del archivo
	if (c == char_traits<char>::eof())
		_eof = true;

	// Asigna el valor leído a "carácter actual"
	_ccar = (char) c;

	// Lleva la cuenta de línea y columna
	if (_ccar == '\n'){
		_linea++;
		_col = 0;
	}
	else
		_col++;
}

bool LyLector::estaLigada() const {
	return _ligada;
}

void LyLector::marcarPosicion(){
	_elinea = _linea;
	_ecol = _col;
}

bool LyLector::fin() const {
	return _eof;
}


//
// Excepción ErrorFormato
//

LyLector::ErrorFormato::ErrorFormato(const string &what) : runtime_error(what) {}

LyLector::ErrorFormato::ErrorFormato(int fila, int col, const string &what)
	: runtime_error(to_string(fila) + ":" + to_string(col) + ": " + what) {}
