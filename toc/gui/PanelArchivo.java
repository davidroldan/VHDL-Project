package toc.gui;

import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFileChooser;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.filechooser.FileNameExtensionFilter;

/**
 * Panel ad-hoc para seleccionar archivos y bloques de BRAM.
 *
 * @see toc.gui.VentanaPpal
 */
public class PanelArchivo extends JPanel {
	/**
	 * Crea un {@code PanelArchivo}.
	 * 
	 * @param titulo Título del panel (propósito).
	 * @param abrir Modifica el comportamiento del cuadro de exploración
	 * emergente de forma que si es {@code true} muestra un cuadro de
	 * apertura de archivo y en caso contrario de guardado.
	 */
	public PanelArchivo(String titulo, boolean abrir){
		setLayout(new BoxLayout(this, BoxLayout.LINE_AXIS));

		// Coloca un borde con título
		setBorder(BorderFactory.createTitledBorder(titulo));

		/*
		 * El panel se compone del selector de bloque,
		 * la ruta del archivo a cargar, el botón de
		 * exploración y el botón para actuar.
		 */
		_bloque = new JComboBox<Integer>();
		_ruta	= new JTextField();

		JButton explorar = new JButton("...");
		_btnActuar = new JButton(titulo);

		_btnActuar.setEnabled(false);

		// Carga el contenido del selector de bloque
		cargarBloques();

		_ruta.getDocument().addDocumentListener(new DocumentListener() {
			
			@Override
			public void removeUpdate(DocumentEvent de) { 
				if (de.getDocument().getLength() == 0)
					_btnActuar.setEnabled(false);
			}
			
			@Override
			public void insertUpdate(DocumentEvent de) {
				_btnActuar.setEnabled(true);
			}
			
			@Override
			public void changedUpdate(DocumentEvent de) { }
		});

		// Crea el selector de archivos
		_fcho = crearFileChooser();

		// Guarda la opción abrir para usarla en la clase anómima
		_abrir = abrir;

		// Acción de explorar
		explorar.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent arg0) {
				int respuesta;
				
				if (_abrir)
					respuesta = _fcho.showOpenDialog(PanelArchivo.this);
				else
					respuesta = _fcho.showSaveDialog(PanelArchivo.this);
				
				if (respuesta == JFileChooser.APPROVE_OPTION)
					_ruta.setText(_fcho.getSelectedFile().getPath());
			}
		});


		// Acción principal del panel
		_btnActuar.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent arg0) {				
				if (_oyente != null)
					_oyente.accionDesencadenada(PanelArchivo.this, _ruta.getText(),
							(Integer) _bloque.getSelectedItem());
			}
		});

		// Inserta los componentes en el panel
		add(_bloque);
		add(Box.createHorizontalStrut(4));
		add(_ruta);
		add(explorar);
		add(Box.createHorizontalStrut(5));
		add(_btnActuar);

		// Fija una dimensión máxima para que no salga desproporcionado
		Dimension dim = _btnActuar.getPreferredSize();
		dim.setSize(Integer.MAX_VALUE, dim.getHeight());
		setMaximumSize(dim);
	}

	/**
	 * Fija el oyente de eventos del panel.
	 * 
	 * @param pal Oyente de eventos del panel.
	 */
	public void setListener(PanelArchivoListener pal){
		_oyente = pal;
	}

	/**
	 * Carga los bloques de BRAM en el selector.
	 */
	private void cargarBloques(){
		for (int i = 0; i <= 19; i++)
			_bloque.addItem(i);
	}

	/**
	 * Crea un selector de archivos.
	 * 
	 * @return el selector de archivos.
	 */
	private JFileChooser crearFileChooser(){
		JFileChooser ret = new JFileChooser();

		FileNameExtensionFilter filtro =
				new FileNameExtensionFilter("Archivo de reproducción/grabación (*.dat)", "dat");

		ret.setFileFilter(filtro);

		ret.setCurrentDirectory(new File("."));
		ret.setMultiSelectionEnabled(false);

		return ret;
	}

	/**
	 * Selector de bloque
	 */
	private JComboBox<Integer> _bloque;

	/**
	 * Ruta de acceso al archivo
	 */
	private JTextField _ruta;

	/**
	 * Selector de archivos
	 */
	private JFileChooser _fcho;

	/**
	 * Opción abrir
	 */
	private boolean _abrir;

	/**
	 * Oyente de eventos del panel
	 */
	private PanelArchivoListener _oyente = null;

	/**
	 * Identificador para la serialización (da igual)
	 */
	private static final long serialVersionUID = 8916031774715989058L;

	/**
	 * Botón que activa la operación e informa a los oyentes
	 */
	private JButton _btnActuar;
}
