/**
 * @file main.cpp
 *
 * @brief Módulo principal del programa.
 */

#include "mflan.h"

int main(int argc, char * argv[]){
	MFlan mflan(argc, argv);

	return mflan.ejecutar();
}
