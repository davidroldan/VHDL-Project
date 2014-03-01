#include <iostream>
#include <iomanip>
#include <cstdio>
#include <clocale>
#include <fstream>
#include <string>
#include <stack>

using namespace std;

// Columnas por fila
const int COLXFIL = 32;

// Escribe una línea (32 bytes) del bloque RAM
void escribirLinea(ostream &out, stack<char> &bloque, int nfil){
		out << "INIT_" << setfill('0') << setw(2) << nfil << " = \"";

		while (!bloque.empty()){
				int aux = bloque.top();

				if (aux < 0) aux += 256;

				out << hex << setfill('0') << setw(2) << aux << dec;

				bloque.pop();
		}

		out << "\"";
}

// Convierte un archivon FLAN
void convertirArchivo(istream &in, ostream &out){
	int nbytes = 0, nfil = 0;
	char cc;
	stack<char> bloque;

	cc = in.get();

	while (!in.eof()) {
		bloque.push(cc);
		nbytes++;

		if (nbytes == COLXFIL){

			if (nfil > 0)
				out << "," << endl;

			escribirLinea(out, bloque, nfil);

			nbytes = 0;
			nfil++;
		}

		cc = in.get();
	}

	// Si se ha terminado sin completar una fila
	if (in.eof() && nbytes < COLXFIL) {

		while (nbytes++ < COLXFIL)
			bloque.push((char) 0);

		if (nfil > 0)
			out << "," << endl;

		escribirLinea(out, bloque, nfil);
	}

	out << endl;
}

int main(int argc, char * argv[]){
	setlocale(LC_ALL, "");

	if (argc != 2) {
		cerr << "Error: número incorrecto de parámetros." << endl << "\tUso: hex <nombre de archivo>." << endl;

		return 1;
	}

	ifstream origen(argv[1], ios::binary);

	if (!origen.is_open()) {
		perror("Error al abrir el archivo");

		return 2;
	}

	convertirArchivo(origen, std::cout);

	return 0;
}
