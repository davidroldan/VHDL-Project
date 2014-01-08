package toc.comm;

import gnu.io.PortInUseException;
import gnu.io.RXTXPort;
import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.UnsupportedCommOperationException;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashSet;
import java.util.Set;
import java.util.TooManyListenersException;

import toc.OyenteTarea;
import toc.comm.ErrorComunicacion;

/**
 * Cargador de archivos en los bloques de memoria de la FPGA
 * para el proyecto de TOC.
 * 
 */
public class Cargador {
	
	/**
	 * Crea un cargador.
	 * 
	 * @param baud Frencuencia de la comunicación (en baudios, bits por segundo)
	 */
	public Cargador(int baud){
		_baud = baud;		
	}
	
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
		
		// Flujo de lectura del puerto serie
		InputStream sin = null;
		
		try {
			
			informeTarea("Abriendo el archivo de origen", 0);
			
			// Abre el archivo de origen (tras ciertas comprobaciones)
			File arch_origen = new File(archivo);
			origen = abrirOrigen(arch_origen);
			
			informeTarea("Conectando por el puerto serie", 0);
			
			// Crea el puerto y lo configura
			puerto = abrirPuerto(npuerto);
			
			// Abre el flujo de salida del puerto
			OutputStream destino = puerto.getOutputStream();
			
			// Abre el flujo de entrada del puerto
			sin = puerto.getInputStream();
			
			informeTarea("Enviando la petición", 5);
			
			// Envía la petición por el puerto serie
			destino.write((byte) 'a');
			
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
			
			if ((byte) respuesta != (byte) 'b')
				throw new ErrorComunicacion("Se recibió una respuesta desconocida: " + respuesta + ".");
			
			informeTarea("Enviando contenido", 10);
			
			// Copia el archivo en el puerto
			int benv = 0;
			int btam = (int) arch_origen.length();
			
			while (origen.available() > 0){
				destino.write(origen.read());
				
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
				
				// Intenta cerrar el archivo de destino
				if (sin != null)
					try { sin.close(); } catch (IOException e) { }
				
				// Intenta cerra el puerto serie
				if (puerto != null)
						puerto.close();			
		}
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
	 * Abre y configura el puerto serie.
	 * 
	 * @param npuerto Nombre del puerto.
	 * 
	 * @return El puerto debidamente configurado.
	 * 
	 * @throws PortInUseException Si el puerto está ocupado o no existe.
	 * @throws UnsupportedCommOperationException Si algunos parámetros de la configuración no se han podido establecer.
	 */
	private SerialPort abrirPuerto(String npuerto) throws PortInUseException, UnsupportedCommOperationException {
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
		
		// Asocia el oyente por el puerto serie
		_oySerie.subscribir(puerto);
		
		return puerto;
	}
	
	/**
	 * Envía un informe de la tarea en curso a los oyentes configurados.
	 * 
	 * @param op Nombre de la operación.
	 * @param progreso Nivel de progreso.
	 */
	private void informeTarea(String op, int progreso){
		for (OyenteTarea oyente : _oyentes)
			oyente.informeProgreso(op, progreso);
	}
	
	/**
	 * Oyente de los eventos serie de la comunicación.
	 *
	 */
	private class OyenteSerie implements gnu.io.SerialPortEventListener {
		
		/**
		 * Subscribe el oyente al puerto serie dado.
		 * 
		 * @param sp Puerto serie.
		 * 
		 * @return si funcionó.
		 */
		public boolean subscribir(SerialPort sp){
			try {
				sp.notifyOnBreakInterrupt(true);
				sp.notifyOnCarrierDetect(true);
				sp.notifyOnCTS(true);
				sp.notifyOnDataAvailable(true);
				sp.notifyOnDSR(true);
				sp.notifyOnFramingError(true);
				sp.notifyOnOutputEmpty(true);
				sp.notifyOnOverrunError(true);
				sp.notifyOnParityError(true);
				sp.notifyOnRingIndicator(true);
				sp.addEventListener(this);
				
				return true;
			}
			catch (TooManyListenersException tmle){
				return false;
			}
		}
		
		@Override
		public void serialEvent(SerialPortEvent spe) {
			String tevento;
			
			switch (spe.getEventType()) {
				case SerialPortEvent.BI :
					tevento = "Break Interrupt"; break;
				case SerialPortEvent.CD :
					tevento = "Carrier Detect"; break;
				case SerialPortEvent.CTS :
					tevento = "CTS"; break;
				case SerialPortEvent.DATA_AVAILABLE :
					tevento = "Data Available"; break;
				case SerialPortEvent.DSR :
					tevento = "DSR"; break;
				case SerialPortEvent.FE :
					tevento = "Framing Error"; break;
				case SerialPortEvent.OUTPUT_BUFFER_EMPTY :
					tevento = "OutputEmpty"; break;
				case SerialPortEvent.OE :
					tevento = "Overrun Error"; break;
				case SerialPortEvent.PE :
					tevento = "Parity Error"; break;
				case SerialPortEvent.RI :
					tevento = "Ring Indicator"; break;
				default :
					tevento = "Desconocido"; break;
			}
			
			System.err.println("Evento Comm: " + tevento + ".");
		}
		
	}
	
	/**
	 * Oyente del puerto serie.
	 */
	private OyenteSerie _oySerie = new OyenteSerie();
	
	/**
	 * Oyentes del progreso de las operaciones.
	 */
	private Set<OyenteTarea> _oyentes = new HashSet<>();
	
	/**
	 * Velocidad del puerto serie (baudios).
	 */
	private int _baud;
} 