package toc.comm;

import gnu.io.PortInUseException;
import gnu.io.SerialPort;
import gnu.io.UnsupportedCommOperationException;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import toc.comm.ErrorComunicacion;

/**
 * Descargador de archivos en los bloques de memoria de la FPGA
 * para el proyecto de TOC.
 * 
 */
public class Descargador extends Comunicador {

	/**
	 * Crea un descargador.
	 * 
	 * @param baud Frencuencia de la comunicación (en baudios, bits por segundo)
	 */
	public Descargador(int baud){
		super(baud);
	}

	/**
	 * Código de petición de descarga.
	 */
	private static final byte COD_DESCARGA = (byte) 0b10000010;

	/**
	 * Código de respuesta: petición admitida.
	 */
	private static final byte COD_ADMITIDA = (byte) 0b10001000;

	/**
	 * Código de respuesta: bloque RAM ocupado.
	 */
	private static final byte COD_OCUPADO = (byte) 0b10001001;

	/**
	 * Descarga un archivo desde la memoria de la FPGA.
	 *  
	 * @param archivo Archivo de destino
	 * @param npuerto Nombre de puerto de comunicación con la FPGA.
	 * @param bloque Bloque de memoria de la FPGA.
	 * 
	 * @throws ErrorComunicacion si se produce un error en la comunicación.
	 */
	public void descargar(String archivo, String npuerto, int bloque) throws ErrorComunicacion {

		SerialPort puerto = null;
		OutputStream destino = null;

		try {

			informeTarea("Creando archivo", 0);

			// Abre el archivo de destino (tras ciertas comprobaciones)
			File arch_origen = new File(archivo);
			destino = abrirDestino(arch_origen);

			informeTarea("Conectando por el puerto serie", 0);

			// Crea el puerto y lo configura
			puerto = abrirPuerto(npuerto);

			// Conecta el oyente
			_oySerie.subscribir(puerto);

			// Abre el flujo de salida del puerto
			OutputStream sout = puerto.getOutputStream();

			// Abre el flujo de entrada del puerto
			InputStream sin = puerto.getInputStream();

			informeTarea("Enviando la petición", 5);

			// Envía la petición por el puerto serie
			sout.write(COD_DESCARGA);

			// Envía el número de puerto
			sout.write((byte) bloque);

			informeTarea("Esperando respuesta", 5);

			// Espera la respuesta (hay timeout)
			int respuesta = sin.read();

			/*
			 * Cuando se agota el tiempo máximo no se lanza
			 * ningún tipo de evento (al menos con RXTX).
			 * 
			 * En el código fuente de RXTX se afirma que la
			 * función read() devuelve -1 en dicho caso.
			 * 
			 */
			if (respuesta == -1)
				throw new ErrorComunicacion("Tiempo de espera superado." +
						" No hubo respuesta.");

			switch ((byte) respuesta) {
				case COD_ADMITIDA :
					break;
				case COD_OCUPADO :
					throw new ErrorComunicacion("El bloque en cuestión está ocupado actualmente.");
				default :
					throw new ErrorComunicacion("Se recibió una respuesta desconocida: " + respuesta + ".");
			}

			informeTarea("Enviando contenido", 10);

			// Descarga el archivo desde el puerto
			int benv = 0;
			int btam = 1024;

			while (sin.available() > 0){
				destino.write(sin.read());

				informeTarea("Recibiendo contenido", (int)(10 + 90 * (double)(benv++) /
						btam));
			}

			informeTarea("Tarea completada", 100);

		} catch (ErrorComunicacion ec) {
			throw ec;

		} catch (IOException ioe) {
			throw new ErrorComunicacion("Error de entrada salida: ", ioe);

		} catch (PortInUseException piue) {
			throw new ErrorComunicacion("No se puede acceder al puerto: " + piue.getMessage());

		} catch (UnsupportedCommOperationException e1) {
			throw new ErrorComunicacion("El controlador de comunicación serie no soporta los parámetros necesarios.");
		}
		finally {
				// Intenta cerrar el archivo de origen
				if (destino != null)
					try { destino.close(); } catch (IOException e) { }

				// Intenta cerra el puerto serie
				if (puerto != null)
						puerto.close();
		}
	}

	/**
	 * Abre el archivo de destino de la descarga, realizando ciertas comprobaciones.
	 * 
	 * @param archivo Archivo de destino.
	 * 
	 * @return Flujo de salida del archivo de destino.
	 * 
	 * @throws ErrorComunicacion en caso de error esperable.
	 * @throws IOException en caso de error desconocido.
	 */
	private OutputStream abrirDestino(File archivo) throws ErrorComunicacion, IOException {

		if (archivo.isDirectory())
			throw new ErrorComunicacion("\"" + archivo + "\" es un directorio.");

		// Omite la comprobación de posibilidad de escritura, habrá una IOException al crear
		// FileOutputStream

		//else if (arch_origen.length() % 2 != 0 || arch_origen.length() > 1024)
		//	throw new ErrorComunicacion("El archivo no cumple los requisitos para ser cargado.");

		// Abre el archivo de origen
		return new FileOutputStream(archivo);
	}

	/**
	 * Oyente del puerto serie.
	 */
	private OyenteSerieDebug _oySerie = new OyenteSerieDebug();
}