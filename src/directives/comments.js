import * as vscode from 'vscode';

const commentsColorsDecoration = vscode.window.createTextEditorDecorationType({
  color: 'rgb(64, 68, 64)',
  fontWeight: 'bold',
  rangeBehavior: vscode.DecorationRangeBehavior.ClosedClosed
});

export default function updateCommentsDecorations() {
  let activeEditor = vscode.window.activeTextEditor;
  if (!activeEditor || activeEditor.document.languageId !== 'rpgle') {
    return;
  }
  const document = activeEditor.document;
  const commentDecorations = [];

  for(let i = 0; i < document.lineCount; i++) {
    const line = document.lineAt(i);
    const text = line.text;

    //comentario de (//)
    if(text.length > 0 && text.trim().startsWith('//')) {
      const startChar = text.indexOf('//');
      const range = new vscode.Range(
        new vscode.Position(i, startChar),
        new vscode.Position(i, text.length)
      );
      commentDecorations.push(range);
    }
    // \* in column 7
    if(text.length > 6 && text[6] === '*') {
      const range = new vscode.Range(
        new vscode.Position(i, 6),
        new vscode.Position(i, text.length)
      );
      commentDecorations.push(range);
    }
  }
  activeEditor.setDecorations(commentsColorsDecoration, commentDecorations);
}