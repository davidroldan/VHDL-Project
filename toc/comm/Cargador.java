package toc.comm;

import gnu.io.PortInUseException;
import gnu.io.SerialPort;
import gnu.io.UnsupportedCommOperationException;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import toc.comm.ErrorComunicacion;

/**
 * Cargador de archivos en los bloques de memoria de la FPGA
 * para el proyecto de TOC.
 * 
 */
public class Cargador extends Comunicador {

	/**
	 * Crea un cargador.
	 * 
	 * @param baud Frencuencia de la comunicación (en baudios, bits por segundo)
	 */
	public Cargador(int baud){
		super(baud);
	}

	/**
	 * Código de petición de descarga.
	 */
	private static final byte COD_CARGA = (byte) 0b10000001;

	/**
	 * Código de respuesta: petición admitida.
	 */
	private static final byte COD_ADMITIDA = (byte) 0b10001000;

	/**
	 * Código de respuesta: bloque RAM ocupado.
	 */
	private static final byte COD_OCUPADO = (byte) 0b10001001;

	/**
	 * Carga un archivo en la memoria de la FPGA.
	 *  
	 * @param archivo Archivo de origen
	 * @param npuerto Nombre de puerto de comunicación con la FPGA.
	 * @param bloque Bloque de memoria de la FPGA.
	 * 
	 * @throws ErrorComunicacion si se produce un error en la comunicación.
	 */
	public void cargar(String archivo, String npuerto, int bloque) throws ErrorComunicacion {

		SerialPort puerto = null;
		InputStream origen = null;

		try {

			informeTarea("Abriendo el archivo de origen", 0);

			// Abre el archivo de origen (tras ciertas comprobaciones)
			File arch_origen = new File(archivo);
			origen = abrirOrigen(arch_origen);

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
			sout.write(COD_CARGA);

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

			// Copia el archivo en el puerto
			int benv = 0;
			int btam = (int) arch_origen.length();

			while (origen.available() > 0){
				sout.write(origen.read());

				informeTarea("Enviando contenido", (int)(10 + 90 * (double)(benv++) /
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
				if (origen != null)
					try { origen.close(); } catch (IOException e) {	}

				// Intenta cerra el puerto serie
				if (puerto != null)
						puerto.close();
		}
	}

	/**
	 * Abre el archivo de origen de la carga, realizando ciertas comprobaciones.
	 * 
	 * @param archivo Archivo de origen.
	 * 
	 * @return Flujo de entrada del archivo de origen.
	 * 
	 * @throws ErrorComunicacion en caso de error esperable.
	 * @throws IOException en caso de error desconocido.
	 */
	private InputStream abrirOrigen(File archivo) throws ErrorComunicacion, IOException {

		if (!archivo.exists())
			throw new ErrorComunicacion("El archivo \"" + archivo + "\" no existe.");

		else if (!archivo.canRead())
			throw new ErrorComunicacion("El archivo \"" + archivo + "\" no se puede leer.");

		else if (archivo.isDirectory())
			throw new ErrorComunicacion("\"" + archivo + "\" es un directorio.");

		//else if (arch_origen.length() % 2 != 0 || arch_origen.length() > 1024)
		//	throw new ErrorComunicacion("El archivo no cumple los requisitos para ser cargado.");

		// Abre el archivo de origen
		return new FileInputStream(archivo);
	}


	/**
	 * Oyente del puerto serie.
	 */
	private OyenteSerieDebug _oySerie = new OyenteSerieDebug();
}
