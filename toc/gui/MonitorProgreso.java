package toc.gui;

import java.awt.Font;

import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.SwingUtilities;

/**
 * Una clase para monitorizar el progreso de una operación. Si parece que
 * la operación va durar un tiempo perceptible (siempre), se mostrará un
 * cuadro de diálogo. Al crear el MonitorProgreso, se le asigna un rango
 * numérico y un texto descriptivo. Conforme la operación progresa,
 * el método {@link #setProgress} permite indicar dentro del rango
 * [min, max] el progreso de la operación.
 * 
 * <p>Es una versión de {@link javax.swing.ProgressMonitor} modal y segura ante hebras.
 *
 * @see javax.swing.ProgressMonitor
 */
public class MonitorProgreso {
	/**
	 * Crea un objeto gráfico para mostrar el progreso.
	 * 
	 * @param padre Componente padre.
	 * @param mensaje Mensaje fijo.
	 * @param nota Mensaje variable.
	 * @param min Progreso mínimo (inicial).
	 * @param max Progreso máximo (final).
	 */
	public MonitorProgreso(JFrame padre, String mensaje,
			String nota, int min, int max) {
		this(padre, mensaje, nota, min, max, false);
	}

	/**
	 * Crea un objeto gráfico para mostrar el progreso.
	 * 
	 * @param padre Componente padre.
	 * @param mensaje Mensaje fijo.
	 * @param nota Mensaje variable.
	 * @param min Progreso mínimo (inicial).
	 * @param max Progreso máximo (final).
	 * @param indeterm Muestra indeterminado
	 * el progreso de la operación.
	 */
	public MonitorProgreso(JFrame padre, String mensaje,
			String nota, int min, int max, boolean indeterm) {
		_padre = padre;
		_mensaje = mensaje;
		_nota = nota;
		_min = min;
		_max = max;

		_dialog = new DialogoProgreso(_padre, indeterm);
	}

	/**
	 * Indica el progreso de la operación monitorizada. Si el valor 
	 * supera o iguala el valor máximo, se cerrará el monitor.
	 * 
	 * @param nv un int indicando el valor actual, entre el mínimo y el máximo
	 * especificados para el componente.
	 */
	public void setProgress(int nv){
		// Si el valor no está dentro de los límites lo trunca
		if (nv >= _max){
			_progreso = _max;

			close();

			return;
		}
		else if (nv < _min)
			_progreso = _min;
		else
			_progreso = nv;

		// Actualiza o empieza a mostrar la interfaz gráfica
		if (_activo)
			_dialog.actualizar();

		else {
			SwingUtilities.invokeLater(new Runnable() {
				public void run() {
					_dialog.setVisible(true);
				}
			});

			_activo = true;
		}
	}

	/**
	 * Indica que la operación se ha completado. Esto ocurre automáticamente cuando
	 * el valor establecido por {@link #setProgress} es >= max, pero su uso tiene
	 * sentido si la operación acaba prematuramente.
	 */
	public void close(){
		SwingUtilities.invokeLater(new Runnable() {
			@Override
			public void run() {
				_dialog.setVisible(false);	
			}
		});

		_activo = false;
	}

	/**
	 * Devuelve el valor mínimo	-- el límite inferior del valor de progreso.
	 * 
	 * @return un int representando el valor mínimo.
	 * 
	 * @see #setMinimum
	 */
	public int getMinimum(){
		return _min;
	}

	/**
	 * Especifica el valor mínimo.
	 * 
	 * @param m un int especificando el valor mínimo.
	 * 
	 * @see #getMinimum
	 */
	public void setMinimum(int m){
		_min = m;
	}

	/**
	 * Devuelve el valor máximo	-- el límite superior del valor de progreso.
	 * 
	 * @see #setMaximum
	 */
	public int getMaximum(){
		return _min;
	}

	/**
	 * Especifica el valor máximo.
	 * 
	 * @param m un int especificando el valor máximo.
	 * 
	 * @see #getMaximum
	 */
	public void setMaximum(int m){
		_max = m;
	}

	/**
	 * Especifica la nota adicional que se muestra junto con el
	 * mensaje fijo.
	 * 
	 * @param nota un String indicando el texto que mostrar.
	 * 
	 * @see #getNote
	 */
	public void setNote(String nota){
		_nota = nota;

		_dialog.actualizar();
	}

	/**
	 * Devuelve la nota adicional que se muestra junto con el
	 * mensaje fijo.
	 * 
	 * @return un String indicando el texto que mostrar.
	 * 
	 * @see #setNote
	 */
	public String getNote(){
		return _nota;
	}

	/**
	 * Cuadro de diálogo para mostrar el progreso.
	 *
	 */
	private class DialogoProgreso extends JDialog {

		/**
		 * Crea un cuadro de diálogo de progreso íntimamente
		 * asociado al MonitorProgreso.
		 * 
		 * @param padre Componente padre.
		 * @param indeterm Muestra indeterminado el progreso.
		 * No se mostrará un porcentaje ni una barra definida.
		 */
		public DialogoProgreso(JFrame padre, boolean indeterm){
			super(padre, true);

			setTitle(_mensaje);
			setResizable(false);
			setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);

			componerInterfaz(indeterm);

			setLocationRelativeTo(padre);
		}

		/**
		 * Crea los componentes visuales de la interfaz.
		 * 
		 * @param indeterm Activación de la indeterminación.
		 */
		private void componerInterfaz(boolean indeterm){

			// Barra de progreso
			_barra = new JProgressBar(_min, _max);
			_barra.setStringPainted(!indeterm);
			_barra.setIndeterminate(indeterm);
			_barra.setString("");

			// Etiqueta del mensaje			
			JLabel lbl_mensaje	= new JLabel(_mensaje);

			lbl_mensaje.setFont(new Font(lbl_mensaje.getFont().getName(), Font.ITALIC,
					lbl_mensaje.getFont().getSize()));

			// Etiqueta de la nota
			_lbl_nota		= new JLabel(_nota);

			// Ubica los componentes
			setLayout(new BoxLayout(getContentPane(), BoxLayout.PAGE_AXIS));

			JPanel panelBarra = new JPanel();
			panelBarra.setLayout(new BoxLayout(panelBarra, BoxLayout.LINE_AXIS));

			panelBarra.add(Box.createHorizontalStrut(10));
			panelBarra.add(_barra);
			panelBarra.add(Box.createHorizontalStrut(10));

			add(Box.createVerticalStrut(8));
			add(lbl_mensaje);
			add(Box.createVerticalGlue());
			add(_lbl_nota);
			add(Box.createVerticalGlue());
			add(panelBarra);
			add(Box.createVerticalStrut(8));

			// Ajusta el tamaño (o lo intenta)
			setSize((int)(lbl_mensaje.getPreferredSize().getWidth() * 3), 
					(int)(_barra.getMinimumSize().getHeight()) * 5);
		}

		/**
		 * Actualiza los componentes.
		 */
		public void actualizar(){
			SwingUtilities.invokeLater(new Runnable() {
				@Override
				public void run() {
					_lbl_nota.setText(_nota);
					
					_barra.setValue(_progreso);
					
					// Suponiendo tanto por ciento
					_barra.setString(_progreso + " %");
				}
			});
		}


		/**
		 * Barra de progreso.
		 */
		private JProgressBar _barra;

		/**
		 * Mensaje variable.
		 */
		private JLabel _lbl_nota;

		/**
		 * IDU de la serialización
		 */
		private static final long serialVersionUID = -2460026640032494160L;
	}


	/**
	 * Componente visual padre.
	 */
	private JFrame _padre;

	/**
	 * Cuadro de diálogo de progreso.
	 */
	private DialogoProgreso _dialog;

	/**
	 * Mensaje fijo.
	 */
	private String _mensaje;

	/**
	 * Mensaje variable.
	 */
	private String _nota;

	/**
	 * Mínimo progreso.
	 */
	private int _min;

	/**
	 * Progreso actual.
	 */
	private int _progreso = _min;

	/**
	 * Máximo progreso.
	 */
	private int _max;

	/**
	 * Indica si está activa la ventana.
	 */
	private boolean _activo = false;
}
