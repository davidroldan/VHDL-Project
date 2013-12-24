# Makefile para MFlan (Windows NMake)

## Variables ##

# Directorio de código objeto
OBJDIR = obj

# Modificadores del compilador de C++
CXXFLAGS = /DSIN_PORTAUDIO /D_CRT_SECURE_NO_WARNINGS

# Módulos generales
MODULOS = obj/notaFPGA.obj obj/mflan.obj obj/lylector.obj

# Módulos de operaciones
MOD_OPS = obj/op_leer.obj obj/op_escalar.obj obj/op_convertir.obj

# Modulos para reproducción
MOD_PA	= obj/op_reproducir.obj obj/ondaseno.obj


## Reglas ##

# Construye el proyecto completo
make: general ops portaudio
	$(CXX) $(CXXFLAGS) main.cpp $(MODULOS) $(MOD_OPS) $(MOD_PA) $(PAFLAGS)

make-pa: general ops
	$(CXX) $(CXXFLAGS) main.cpp $(MODULOS) $(MOD_OPS)

# Reglas para compilar objetos de operación
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

# Módulos generales
general: $(MODULOS)

# Operación de reproducción con PortAudio
portaudio: $(MOD_PA)

# Operaciones
ops : $(MOD_OPS)

# Creación de la carpeta para meter los códigos objeto
$(OBJDIR) : 
	mkdir -p $(OBJDIR)

# Limpia lo generado
clean:
	del -r obj
