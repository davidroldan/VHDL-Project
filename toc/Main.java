package toc;

import java.util.Enumeration;
import java.util.Vector;

import javax.swing.JOptionPane;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

import toc.gui.VentanaPpal;

import gnu.io.CommPortIdentifier;
import gnu.io.NoSuchPortException;
import gnu.io.PortInUseException;

/**
 * Clase principal
 *
 */
public class Main {
	
	/**
	 * Método de entrada.
	 * 
	 * @param args Admite nombres de puertos extra (úsese con cuidado).
	 * 
	 * @throws PortInUseException 
	 * @throws NoSuchPortException 
	 */
	public static void main(String[] args) {		
		// Obtiene los puertos (o lo intenta)
		Vector<String> idpuertos = obtenerPuertos();
		
		for (String arg : args)
			if (arg.charAt(0) == '+')
				idpuertos.add(arg.substring(1));
		
		// Usa el estilo propio del sistema
		try {
			UIManager.setLookAndFeel(
			            UIManager.getSystemLookAndFeelClassName());
		} catch (ClassNotFoundException | InstantiationException
				| IllegalAccessException | UnsupportedLookAndFeelException e) {
			e.printStackTrace();
		}
		
		if (idpuertos.isEmpty()) {
			
			// Muestra un mensaje y para la ejecución
			
			String ENDL = System.getProperty("line.separator");
			
			JOptionPane.showMessageDialog(null,
					"No se encontraron puertos serie en el equipo." + ENDL + ENDL +
					"Tal vez se deba a que RxTx no está bien configurado." + ENDL +
					"Intente: \"java gnu.io.Configure\" con el nivel de privilegios" + ENDL +
					"adecuado.",
					"Cargador del proyecto TOC",
					JOptionPane.ERROR_MESSAGE);
		
			System.exit(1);
		}
		else {
			
			// Carga la ventana principal
			
			VentanaPpal vp = new VentanaPpal(
					(String[]) idpuertos.toArray(
							new String[idpuertos.size()]));
			
			vp.setDefaultCloseOperation(VentanaPpal.EXIT_ON_CLOSE);
					
			vp.setVisible(true);
		}
		
	}
		
	static private Vector<String> obtenerPuertos(){
		Vector<String> idpuertos = new Vector<String>();
		
		// Obtiene los identificadores de puerto (o lo intenta)
		@SuppressWarnings("unchecked")
		Enumeration<CommPortIdentifier> puertos =
				CommPortIdentifier.getPortIdentifiers();
		
		while (puertos.hasMoreElements()) {
			CommPortIdentifier cpi = puertos.nextElement();
	
			if (cpi.getPortType() == CommPortIdentifier.PORT_SERIAL)
				idpuertos.add(cpi.getName());
		}
		
		return idpuertos;
	}
	
	private Main (){}
}
