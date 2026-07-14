import * as vscode from 'vscode';
import { createRequire } from 'module';

const require = createRequire(import.meta.url);
const declarationsSchema = require('../schemas/declarations.json');
const declarationsStart = [
  ...declarationsSchema.rpgle_declaraciones.linea_unica,
  ...declarationsSchema.rpgle_declaraciones.bloque_con_cierre,
].map(({ inicio }) => inicio);
const declarationsEnd = [
  ...declarationsSchema.rpgle_declaraciones.bloque_con_cierre
].map(({ cierre }) => cierre);
const declarations = [...declarationsStart, ...declarationsEnd];

// Definimos los estilos de decoración para los márgenes
const colorDeclarations = vscode.window.createTextEditorDecorationType({
  color: 'rgba(150, 2, 2, 1)',
  fontWeight: 'bold',
  rangeBehavior: vscode.DecorationRangeBehavior.ClosedClosed
});

export default function colorDeclarationsDecorations() {
  const activeEditor = vscode.window.activeTextEditor;
  if (!activeEditor || activeEditor.document.languageId !== 'rpgle') {
    return;
  }
  const document = activeEditor.document;
  const decorations = [];

  for(let i = 0; i < document.lineCount; i++) {
    const line = document.lineAt(i);
    const text = line.text;

    // Recorremos cada declaración en el JSON
    for (const declaration of declarations) {
      const regex = new RegExp(`\\b${declaration}\\b`, 'g');
      let match;
      while ((match = regex.exec(text)) !== null) {
        const startPos = new vscode.Position(i, match.index);
        const endPos = new vscode.Position(i, match.index + match[0].length);
        const range = new vscode.Range(startPos, endPos);
        decorations.push(range);
      }
    }

  }

  activeEditor.setDecorations(colorDeclarations, decorations);
}