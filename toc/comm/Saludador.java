package toc.comm;

import gnu.io.PortInUseException;
import gnu.io.SerialPort;
import gnu.io.UnsupportedCommOperationException;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import toc.comm.ErrorComunicacion;

/**
 * Prueba la conexión entre la FPGA y el ordenador.
 * 
 */
public class Saludador extends Comunicador {

	/**
	 * Crea un saludador.
	 * 
	 * @param baud Frencuencia de la comunicación (en baudios, bits por segundo)
	 */
	public Saludador(int baud){
		super(baud);
	}

	/**
	 * Código de saludo.
	 */
	private static final byte COD_SALUDO = (byte) 0b10000011;

	/**
	 * Respuesta esperada de la FPGA.
	 */
	private static final byte COD_RESPUESTA = (byte) 0b10001011;

	/**
	 * Comprueba la conexión con la FPGA. Si el método finaliza
	 * sin haber lanzado excepciones la prueba habrá finalizado con éxito.
	 *  
	 * @param npuerto Nombre de puerto de comunicación con la FPGA.
	 * 
	 * @throws ErrorComunicacion si se produce un error en la comunicación.
	 */
	public void saludar(String npuerto) throws ErrorComunicacion {

		SerialPort puerto = null;

		try {
			informeTarea("Conectando por el puerto serie", 0);

			// Crea el puerto y lo configura
			puerto = abrirPuerto(npuerto);

			// Conecta el oyente
			_oySerie.subscribir(puerto);

			// Abre el flujo de salida del puerto
			OutputStream destino = puerto.getOutputStream();

			// Abre el flujo de entrada del puerto
			InputStream sin = puerto.getInputStream();

			informeTarea("Enviando el saludo", 10);

			// Envía la petición por el puerto serie
			destino.write(COD_SALUDO);

			informeTarea("Esperando respuesta", 20);

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

			if ((byte) respuesta != COD_RESPUESTA)
				throw new ErrorComunicacion("Se recibió una respuesta inesperada: " + respuesta + ".");

			informeTarea("Respuesta recibida", 100);

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
				// Intenta cerra el puerto serie
				if (puerto != null)
						puerto.close();
		}
	}


	/**
	 * Oyente del puerto serie.
	 */
	private OyenteSerieDebug _oySerie = new OyenteSerieDebug();
}
