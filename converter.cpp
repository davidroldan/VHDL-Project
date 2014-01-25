//BMP 32-bit converter

#include <iostream>
#include <string>
#include <fstream>
using namespace std;

int bitMap[500][500];
int width, height;

string getFileName(){
	string a;
	cout << ".BMP File: ";
	cin >> a;
	if (a.substr(a.size()-4,4) != ".bmp") a += ".bmp";
	return a;
}

void readPixels(fstream &file){
	unsigned int aux;
	file.seekg(0x36, ios::beg);
	for (int i = 0; i < height ; i++){
		for (int j = 0; j < width; j++){
			file.read((char*) &aux, sizeof(int));
			if (aux == 0) bitMap[height - i - 1][j] = 0;
			else bitMap[height - 1 - i][j] = 1;
		}
	}
}

void outputPixels(){
	cout << endl << "Width: " << width << ", Height: " << height << endl << endl;
	for (int i = 0; i < height; i++){
		for (int j = 0; j < width; j++){
			cout << bitMap[i][j];
		}
		cout << endl;
	}
}

void createVHD(){
	string entityName;
	cin.sync();
	cout << "VHD entity name: ";
	cin >> entityName;
	cout << endl << "Creating VHD Module..." << endl << endl;
	ofstream fout;
	fout.open(entityName + ".vhd");
	fout << "----------------------------------------------------------------------------------\n"
		<< "-- Archivo autogenerado con 'converter.cpp'" << endl
		<< "----------------------------------------------------------------------------------\n"
		<< "library IEEE;" << endl
		<< "use IEEE.STD_LOGIC_1164.ALL;" << endl
		<< "use IEEE.STD_LOGIC_UNSIGNED.ALL;" << endl
		<< "use IEEE.STD_LOGIC_ARITH.ALL;" << endl << endl
		<< "use work.tipos.all;" << endl << endl
		<< "entity " << entityName << " is" << endl
		<< "\t" << "generic(N: integer := " << width << "; M: integer := "<< height <<");" << endl
		<< "\t" << "port(" << endl
		<< "\t\t" << "hcnt: in std_logic_vector(8 downto 0);" << endl
		<< "\t\t" << "vcnt: in std_logic_vector(9 downto 0);" << endl
		<< "\t\t" << "hcnt_aux: in std_logic_vector(8 downto 0);" << endl
		<< "\t\t" << "vcnt_aux: in std_logic_vector(9 downto 0);" << endl
		<< "\t\t" << "pintar: out std_logic;" << endl
		<< "\t\t" << "currentobject: out vga_object --el tipo vga_object esta definido en tipos.vhd" << endl
		<< "\t);\n" << "end vga_recButton;" << endl
		<< endl
		<< "architecture arch of " << entityName << " is" << endl << endl
		<< "type " << entityName << "_img_type is array (M*2 downto 0) of std_logic_vector(N downto 0);" << endl
		<< "signal " << entityName <<"_img : " << entityName << "_img_type := (" << endl;
	for (int i = 0; i < height; i++){
	for (int k = 0; k < 2; k++){
		fout << "\"";
		for (int j = 0; j < width; j++){
			fout << bitMap[i][j];
		}
		fout << "\"";
		if (k == 0) fout << ", ";
	}
		if (i < height - 1) fout << ", " << endl;
	}
	fout << ");" << endl << endl << "begin" << endl << endl
		<< "currentobject <= object; --Modificar el objeto para el color que se necesite" << endl << endl
		<< "pintar_" << entityName << ": process(hcnt, vcnt)" << endl
		<< "begin" << endl
		<< "\t" << "if hcnt - hcnt_aux > N or vcnt - vcnt_aux > M*2 then" << endl
		<< "\t\t" << "pintar <= '0';" << endl
		<< "\t" << "else pintar <= image(conv_integer(vcnt - vcnt_aux))(conv_integer(hcnt - hcnt_aux));" << endl
		<< "\t" << "end if;" << endl << endl
		<< "end process;" << endl << endl
		<< "end arch;";
	fout.close();
	cout << "Done.";
}


int main(){
	string filePath = getFileName();
	fstream file;
	file.open(filePath.c_str(), ios::in | ios::binary);
	if (!file.is_open()){
		cout << "File does not exist or could not be opened.";
		cin.sync();
		cin.get();
		return 0;
	}
	int filesize;
	file.seekg(2 ,ios::beg);
	file.read((char*) &filesize, sizeof(int));
	file.seekg(0x12 ,ios::beg);
	file.read((char*) &width, sizeof(int));
	file.seekg(0x16 ,ios::beg);
	file.read((char*) &height, sizeof(int));
	readPixels(file);
	file.close();
	outputPixels();
	createVHD();
	cin.sync();
	cin.get();
}