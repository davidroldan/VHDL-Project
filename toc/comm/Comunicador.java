package toc.comm;

import java.util.HashSet;
import java.util.Set;

import toc.OyenteTarea;
import gnu.io.PortInUseException;
import gnu.io.RXTXPort;
import gnu.io.SerialPort;
import gnu.io.UnsupportedCommOperationException;

/**
 * Clase abstracta base para las clases que desarrollen algún
 * tipo de comunicación por el puerto serie.
 * 
 * <p>Controla además el envío de informes de tarea.
 */
public abstract class Comunicador {

	/**
	 * Crea un cargador.
	 * 
	 * @param baud Frencuencia de la comunicación (en baudios, bits por segundo)
	 */
	protected Comunicador(int baud){
		_baud = baud;
	}

	/**
	 * Abre y configura el puerto serie.
	 * 
	 * @param npuerto Nombre del puerto.
	 * 
	 * @return El puerto debidamente configurado.
	 * 
	 * @throws PortInUseException Si el puerto está ocupado o no existe.
	 * @throws UnsupportedCommOperationException Si algunos parámetros de la configuración no se han podido establecer.
	 */
	protected SerialPort abrirPuerto(String npuerto) throws PortInUseException, UnsupportedCommOperationException {
		// Abre el puerto
		// Forma sencilla pero poco canónica y no conforme a la especificación
		SerialPort puerto = new RXTXPort(npuerto);

		// Configura el puerto
		puerto.setSerialPortParams(_baud, SerialPort.DATABITS_8,
						SerialPort.STOPBITS_1, SerialPort.PARITY_NONE);

		puerto.setDTR(false);
		puerto.setRTS(false);

		// Establece un retardo máximo para la lectura
		puerto.enableReceiveTimeout(5000);

		return puerto;
	}

	/**
	 * Registra un oyente del progreso de las operaciones.
	 * 
	 * @param oyente Dicho oyente.
	 */
	public void addOyenteTarea(OyenteTarea oyente){
		_oyentes.add(oyente);
	}

	/**
	 * Envía un informe de la tarea en curso a los oyentes configurados.
	 * 
	 * @param op Nombre de la operación.
	 * @param progreso Nivel de progreso.
	 */
	protected void informeTarea(String op, int progreso){
		for (OyenteTarea oyente : _oyentes)
			oyente.informeProgreso(op, progreso);
	}


	/**
	 * Oyentes del progreso de las operaciones.
	 */
	private Set<OyenteTarea> _oyentes = new HashSet<>();

	/**
	 * Velocidad del puerto serie (baudios).
	 */
	protected int _baud;
}
