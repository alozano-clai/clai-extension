import * as vscode from 'vscode';

const leftMarginDecoration = vscode.window.createTextEditorDecorationType({
  border: '1px dotted rgba(255, 255, 0, 0.4)',
  rangeBehavior: vscode.DecorationRangeBehavior.ClosedClosed
});

const rightMarginDecoration = vscode.window.createTextEditorDecorationType({
  backgroundColor: 'rgba(255, 0, 0, 0.15)',
  border: '1px dotted rgba(255, 0, 0, 0.4)',
  rangeBehavior: vscode.DecorationRangeBehavior.ClosedClosed
});

export default function updateOutlineColorsDecorations() {
  let activeEditor = vscode.window.activeTextEditor;
  if (!activeEditor || activeEditor.document.languageId !== 'rpgle') {
    return;
  }
  const document = activeEditor.document;
  const leftDecorations = [];
  const rightDecorations = [];

  // Recorremos línea por línea el documento
  for (let i = 0; i < document.lineCount; i++) {
    const line = document.lineAt(i);
    const text = line.text;

    // --- CASO 1: Margen Izquierdo (Columnas 0 a 7) ---
    // Si la línea tiene texto en ese rango, coloreamos únicamente hasta el carácter 7
    if (text.length > 0) {
      const endChar = Math.min(7, text.length);
      const leftSegment = text.substring(0, endChar);
      if (leftSegment.trim().length > 0) {
        const range = new vscode.Range(
          new vscode.Position(i, 0),
          new vscode.Position(i, endChar)
        );
        leftDecorations.push(range);
      }
    }

    // --- CASO 2: Margen Derecho (Columna 80 en adelante) ---
    // Si el texto se desborda más allá del carácter 80, coloreamos el resto de la línea
    if (text.length > 80) {
      const range = new vscode.Range(
        new vscode.Position(i, 80),
        new vscode.Position(i, text.length)
      );
      rightDecorations.push(range);
    }
  }

  // Aplicamos los estilos al editor activo
  activeEditor.setDecorations(leftMarginDecoration, leftDecorations);
  activeEditor.setDecorations(rightMarginDecoration, rightDecorations);
}