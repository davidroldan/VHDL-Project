package toc.comm;

import java.io.IOException;

/**
 * Error en la comunicación con la FPGA.
 * 
 * @see toc.comm.Cargador
 */
public class ErrorComunicacion extends IOException {

	/**
	 * Crea una excepción {@code ErrorComunicacion} con mensaje.
	 * 
	 * @param message Mensaje.
	 */
	public ErrorComunicacion(String message) {
		super(message);
	}

	/**
	 * Crea una excepción {@code ErrorComunicacion} con causa.
	 * 
	 * @param cause Causa.
	 */
	public ErrorComunicacion(Throwable cause) {
		super(cause);
	}

	/**
	 * Crea una excepción {@code ErrorComunicacion} con mensaje y causa.
	 * 
	 * @param message Mensaje.
	 * @param cause Causa.
	 */
	public ErrorComunicacion(String message, Throwable cause) {
		super(message, cause);
	}

	/**
	 * Para serialización.
	 */
	private static final long serialVersionUID = 3377944444505694687L;
}
