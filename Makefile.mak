# Makefile para MFlan (Windows NMake)

## Variables ##

# Directorio de código objeto
OBJDIR = obj

# Modificadores del compilador de C++
# Eliminar /DSIN_PORTAUDIO para la compilación general
CXXFLAGS = /DSIN_PORTAUDIO /D_CRT_SECURE_NO_WARNINGS

# Módulos generales
MODULOS = obj/notaFPGA.obj obj/mflan.obj obj/lylector.obj

# Módulos de operaciones
MOD_OPS = obj/op_leer.obj obj/op_escalar.obj obj/op_convertir.obj

# Modulos para reproducción
MOD_PA	= obj/op_reproducir.obj obj/ondaseno.obj

# Modificadores de enlace para PA
PAFLAGS	= portaudio_x64.lib portaudiocpp_x64.lib


## Reglas ##

# Construye el proyecto completo
make: $(OBJDIR) general ops portaudio
	$(CXX) $(CXXFLAGS) main.cpp $(MODULOS) $(MOD_OPS) $(MOD_PA) $(PAFLAGS)

make-pa: $(OBJDIR) general ops
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

# Reglas para compilar los módulos de reproducción
obj/ondaseno.obj: ondaseno.cpp ondaseno.h
	$(CXX) $(CXXFLAGS) /c /Fo$@ /I. /Iinclude ondaseno.cpp

obj/op_reproducir.obj: ops/op_reproducir.cpp ops/op_reproducir.h
	$(CXX) $(CXXFLAGS) /c /Fo$@ /I. /Iinclude ops/op_reproducir.cpp

# Módulos generales
general: $(MODULOS)

# Operación de reproducción con PortAudio
portaudio: $(MOD_PA)

# Operaciones
ops : $(MOD_OPS)

# Creación de la carpeta para meter los códigos objeto
$(OBJDIR) : 
	mkdir $(OBJDIR)

# Limpia lo generado
clean:
	del obj
	rmdir obj
