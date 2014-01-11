package toc.gui;

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;

import javax.swing.JFrame;

import toc.OyenteTarea;
import toc.comm.Cargador;
import toc.comm.Descargador;
import toc.comm.ErrorComunicacion;
import toc.comm.Saludador;

/**
 * Ventana principal del cargador.
 *
 */
public class VentanaPpal extends JFrame {

	/**
	 * Crea la ventana principal.
	 * 
	 * @param nompuertos Nombres de los puertos.
	 */
	public VentanaPpal(String[] nompuertos){
		setTitle("Cargador del proyecto TOC");
		setSize(400, 180);
		setResizable(false);
		setLocationRelativeTo(null);

		// Crea el selector de puertos
		_puerto = new JComboBox<String>(nompuertos);

		// Panel central
		JPanel panelCentral = new JPanel();
		panelCentral.setLayout(new BoxLayout(panelCentral, BoxLayout.PAGE_AXIS));

		PanelArchivo cargar = new PanelArchivo("Cargar", true);
		PanelArchivo descargar = new PanelArchivo("Descargar", false);

		panelCentral.add(cargar);
		panelCentral.add(Box.createVerticalStrut(5));
		panelCentral.add(descargar);
		panelCentral.add(Box.createVerticalGlue());

		OyenteCarga oyCarga = new OyenteCarga();
		OyenteDescarga oyDescarga = new OyenteDescarga();

		cargar.setListener(oyCarga);
		descargar.setListener(oyDescarga);

		JPanel panelPuerto = crearPanelPuerto();

		add(panelPuerto, BorderLayout.NORTH);
		add(panelCentral, BorderLayout.CENTER);

		setSize(400, (int) (cargar.getPreferredSize().getHeight() * 4));
	}

	/**
	 * Crea y devuelve el panel de selección de puerto.
	 * 
	 * @return el panel de selección de puerto.
	 */
	private JPanel crearPanelPuerto(){
		JPanel panelPuerto = new JPanel();

		panelPuerto.setBorder(BorderFactory.createTitledBorder("Puerto"));
		panelPuerto.setLayout(new BoxLayout(panelPuerto, BoxLayout.LINE_AXIS));

		JButton btn_compr = new JButton("Comprobar");

		panelPuerto.add(_puerto);
		panelPuerto.add(Box.createHorizontalGlue());
		panelPuerto.add(btn_compr);

		btn_compr.addActionListener(new OyenteSaludo());

		return panelPuerto;
	}


	/**
	 * Oyente de la petición de carga.
	 */
	private class OyenteCarga implements PanelArchivoListener, OyenteTarea {
		@Override
		public void accionDesencadenada(final PanelArchivo sender, final String narchivo,
				final int bloque) {

			// Crea un monitor de progreso
			_monprogre = new MonitorProgreso(VentanaPpal.this,
					"Cargando...", "Iniciando...", 	0, 100);

			new Thread (){
				@Override
				public void run(){
					// Crea un cargador y se inscribe como oyente
					Cargador carg = new Cargador(9600);

					carg.addOyenteTarea(OyenteCarga.this);

					try {
						carg.cargar(narchivo, _puerto.getSelectedItem().toString(),
								bloque);

						informeProgreso("Finalizado", 100);

					} catch (final ErrorComunicacion ec) {
						SwingUtilities.invokeLater(new Runnable (){
							public void run (){
								_monprogre.close();
								
								JOptionPane.showMessageDialog(VentanaPpal.this,
										ec.getMessage(),
										getTitle(),
										JOptionPane.ERROR_MESSAGE);
							}
						});
					}
				}
			}.start();
		}

		@Override
		public void informeProgreso(String opActual, int progreso) {
			_monprogre.setProgress(progreso);
			_monprogre.setNote(opActual);
		}
	}

	/**
	 * Oyente de la petición de descarga.
	 */
	private class OyenteDescarga implements PanelArchivoListener, OyenteTarea {
		@Override
		public void accionDesencadenada(final PanelArchivo sender, final String narchivo,
				final int bloque) {

			// Crea un monitor de progreso
			_monprogre = new MonitorProgreso(VentanaPpal.this,
					"Descargando...", "Iniciando...", 	0, 100);

			new Thread (){
				@Override
				public void run(){
					// Crea un descargador y se registra como oyente
					Descargador dcarg = new Descargador(9600);

					dcarg.addOyenteTarea(OyenteDescarga.this);

					try {
						dcarg.descargar(narchivo, _puerto.getSelectedItem().toString(),
								bloque);

						informeProgreso("Finalizado", 100);

					} catch (final ErrorComunicacion ec) {
						SwingUtilities.invokeLater(new Runnable (){
							public void run (){
								_monprogre.close();
								
								JOptionPane.showMessageDialog(VentanaPpal.this,
										ec.getMessage(),
										getTitle(),
										JOptionPane.ERROR_MESSAGE);
							}
						});
					}
				}
			}.start();
		}

		@Override
		public void informeProgreso(String opActual, int progreso) {
			_monprogre.setProgress(progreso);
			_monprogre.setNote(opActual);

		}
	}

	/**
	 * Oyente de la petición de saludo.
	 */
	private class OyenteSaludo implements ActionListener, OyenteTarea {

		@Override
		public void actionPerformed(ActionEvent e) {

			// Crea un monitor de progreso
			_monprogre = new MonitorProgreso(VentanaPpal.this,
					"Probando...", "Iniciando...", 	0, 100);

			new Thread (){
				@Override
				public void run(){
					// Crea un saludador y se registra como oyente
					Saludador salu = new Saludador(9600);

					salu.addOyenteTarea(OyenteSaludo.this);

					try {
						salu.saludar(_puerto.getSelectedItem().toString());

						// Si ha terminado la comprobación ha sido exitosa
						informeProgreso("Finalizado", 100);

						SwingUtilities.invokeLater(new Runnable (){
							public void run (){
								JOptionPane.showMessageDialog(VentanaPpal.this,
										"FPGA detectada." ,
										getTitle(),
										JOptionPane.INFORMATION_MESSAGE);
							}
						});

					} catch (final ErrorComunicacion ec) {
						SwingUtilities.invokeLater(new Runnable (){
							public void run (){
								_monprogre.close();
								
								JOptionPane.showMessageDialog(VentanaPpal.this,
										ec.getMessage(),
										getTitle(),
										JOptionPane.ERROR_MESSAGE);
							}
						});
					}
				}
			}.start();
		}

		@Override
		public void informeProgreso(String opActual, int progreso) {
			_monprogre.setProgress(progreso);
			_monprogre.setNote(opActual);

		}
	}


	/**
	 * Selector de puerto
	 */
	private JComboBox<String> _puerto;

	/**
	 * Monitor de progreso de una tarea
	 */
	private MonitorProgreso _monprogre = null;

	/**
	 * Identificador para la serialización (da igual)
	 */
	private static final long serialVersionUID = -950940502339782942L;
}
