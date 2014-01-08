package toc;

import java.util.EventListener;

/**
 * Oyente de tareas.
 *
 */
public interface OyenteTarea extends EventListener {

	/**
	 * Método de información del progreso. Se llamará cuando acontezca algún
	 * cambio o avance suficiente en la tarea escuchada.
	 * 
	 * @param opActual Descripción de la operación actual.
	 * @param progreso Progreso porcentual.
	 */
	public void informeProgreso(String opActual, int progreso);
}
