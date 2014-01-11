# Makefile para MFlan

## Variables ##

# Directorio de código objeto
OBJDIR = obj

# Bibliotecas a enlazar para PortAudio
PAFLAGS = `pkg-config portaudiocpp --libs`

# Modificadores del compilador de C++
CXXFLAGS = -Wall -Wextra -pedantic -Wfatal-errors -O3

# En la regla "sin PortAudio" define el macro SIN_PORTAUDIO
make-pa : CXXFLAGS := $(CXXFLAGS) -DSIN_PORTAUDIO

# Módulos generales
MODULOS = obj/notaFPGA.o obj/mflan.o

# Módulos de operaciones
MOD_OPS = obj/op_leer.o obj/op_escalar.o obj/op_convertir.o

# Modulos para reproducción
MOD_PA	= obj/op_reproducir.o obj/ondaseno.o


## Reglas ##

# Construye el proyecto completo
make: general ops portaudio
	$(CXX) $(CXXFLAGS) main.cpp $(MODULOS) $(MOD_OPS) $(MOD_PA) $(OBJDIR)/lylector.o $(PAFLAGS) -o mflan

make-pa: general ops
	$(CXX) $(CXXFLAGS) main.cpp $(MODULOS) $(MOD_OPS) $(OBJDIR)/lylector.o -o mflan

# Regla para compilar objetos de operación
obj/op_%.o: ops/op_%.cpp ops/op_%.h
	$(CXX) $(CXXFLAGS) -c -o $@ -I. $<

# Regla para compilar objetos generales
obj/%.o: %.cpp %.h | $(OBJDIR)
	$(CXX) $(CXXFLAGS) -c -I. -o $@ $<

# Módulos generales
general: $(MODULOS) lylector

# Operación de reproducción con PortAudio
portaudio: $(MOD_PA)

# Operaciones
ops : $(MOD_OPS)

# Regla para el lector del formato humanamente legible
lylector: lylector.cpp lylector.h
	$(CXX) $(CXXFLAGS) -c -I. -std=c++11 -o obj/lylector.o lylector.cpp

# Creación de la carpeta para meter los códigos objeto
$(OBJDIR) : 
	mkdir -p $(OBJDIR)

# Limpia lo generado
clean:
	$(RM) -r obj
