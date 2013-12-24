# Makefile para MFlan (Windows NMake)

## Variables ##

# Directorio de c�digo objeto
OBJDIR = obj

# Modificadores del compilador de C++
CXXFLAGS = /DSIN_PORTAUDIO /D_CRT_SECURE_NO_WARNINGS

# M�dulos generales
MODULOS = obj/notaFPGA.obj obj/mflan.obj obj/lylector.obj

# M�dulos de operaciones
MOD_OPS = obj/op_leer.obj obj/op_escalar.obj obj/op_convertir.obj

# Modulos para reproducci�n
MOD_PA	= obj/op_reproducir.obj obj/ondaseno.obj


## Reglas ##

# Construye el proyecto completo
make: general ops portaudio
	$(CXX) $(CXXFLAGS) main.cpp $(MODULOS) $(MOD_OPS) $(MOD_PA) $(PAFLAGS)

make-pa: general ops
	$(CXX) $(CXXFLAGS) main.cpp $(MODULOS) $(MOD_OPS)

# Reglas para compilar objetos de operaci�n
obj/op_leer.obj: ops/op_leer.cpp ops/op_leer.h
	$(CXX) $(CXXFLAGS) /c /Fo$@ /I. ops/op_leer.cpp

obj/op_escalar.obj: ops/op_escalar.cpp ops/op_escalar.h
	$(CXX) $(CXXFLAGS) /c /Fo$@ /I. ops/op_escalar.cpp

obj/op_convertir.obj: ops/op_convertir.cpp ops/op_convertir.h
	$(CXX) $(CXXFLAGS) /c /Fo$@ /I. ops/op_convertir.cpp

# Reglas para compilar objetos generales
obj/notaFPGA.obj: notaFPGA.cpp notaFPGA.h
	$(CXX) $(CXXFLAGS) /c /I. /Fo$@ notaFPGA.cpp
obj/mflan.obj: mflan.cpp mflan.h
	$(CXX) $(CXXFLAGS) /c /I. /Fo$@ mflan.cpp
obj/lylector.obj: lylector.cpp lylector.h
	$(CXX) $(CXXFLAGS) /c /I. /Fo$@ lylector.cpp

# M�dulos generales
general: $(MODULOS)

# Operaci�n de reproducci�n con PortAudio
portaudio: $(MOD_PA)

# Operaciones
ops : $(MOD_OPS)

# Creaci�n de la carpeta para meter los c�digos objeto
$(OBJDIR) : 
	mkdir -p $(OBJDIR)

# Limpia lo generado
clean:
	del -r obj
