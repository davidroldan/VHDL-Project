package toc.gui;

import java.util.EventListener;

/**
 * Intefaz común a los oyentes de {@link toc.gui.PanelArchivo}.
 *
 * @see toc.gui.PanelArchivo
 * @see toc.gui.VentanaPpal
 */
public interface PanelArchivoListener extends EventListener {

	/**
	 * Método de aviso tras desencadenar la acción del panel.
	 * 
	 * @param sender Control que emite el mensaje.
	 * @param narchivo Nombre del archivo seleccionado.
	 * @param bloque Bloque RAM.
	 */
	public void accionDesencadenada(PanelArchivo sender, String narchivo, int bloque);
}
