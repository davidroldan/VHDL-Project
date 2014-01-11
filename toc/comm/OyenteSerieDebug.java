package toc.comm;

import java.util.TooManyListenersException;

import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;

/**
 * Oyente de los eventos serie de la comunicación que muestra un
 * mensaje en consola cuando estos ocurren.
 *
 */
class OyenteSerieDebug implements gnu.io.SerialPortEventListener {

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
