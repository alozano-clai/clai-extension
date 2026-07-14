import * as vscode from 'vscode';
import updateOutlineColorsDecorations from './src/directives/outlineColors.js';
import updateCommentsDecorations from './src/directives/comments.js';
import colorDeclarationsDecorations from './src/directives/declarationsColor.js';

/**
 * @param {vscode.ExtensionContext} context
 */
export function activate(context) {
	vscode.window.showInformationMessage('RPGLE Extension Activated! CLAIII');
	console.log('RPGLE Extension Activated! CLAIII');
	let activeEditor = vscode.window.activeTextEditor;


	// Gatillo 1: Si hay un editor abierto al iniciar la extensión, decorarlo
	if (activeEditor) {
		updateOutlineColorsDecorations();
		updateCommentsDecorations();
		colorDeclarationsDecorations();
	}

	// Gatillo 2: Si el usuario cambia de pestaña/archivo activo
	vscode.window.onDidChangeActiveTextEditor(editor => {
		activeEditor = editor;
		if (editor) {
			updateOutlineColorsDecorations();
			updateCommentsDecorations();
			colorDeclarationsDecorations();
		}
	}, null, context.subscriptions);

	// Gatillo 3: Si el usuario edita o escribe en el archivo (tiempo real)
	vscode.workspace.onDidChangeTextDocument(event => {
		if (activeEditor && event.document === activeEditor.document) {
			updateOutlineColorsDecorations();
			updateCommentsDecorations();
			colorDeclarationsDecorations();
		}
	}, null, context.subscriptions);

	// The command has been defined in the package.json file
	// Now provide the implementation of the command with  registerCommand
	// The commandId parameter must match the command field in package.json
	const disposable = vscode.commands.registerCommand('clai-extension-rpgle.helloWorld', function () {
		// The code you place here will be executed every time your command is executed

		// Display a message box to the user
		vscode.window.showInformationMessage('Hello World from clai-extension-rpgle!');
	});

	context.subscriptions.push(disposable);
}

// This method is called when your extension is deactivated
export function deactivate() { }
