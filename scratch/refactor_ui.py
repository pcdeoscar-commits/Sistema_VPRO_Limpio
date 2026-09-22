import os
import re

def clean_and_import():
    functions_to_remove = ['_get', '_post', '_put', '_delete', '_badge', '_color_estatus']
    
    import_stmt = "from modulos_prueba.utils_frontend import _get, _post, _put, _delete, _badge, _color_estatus\n"
    
    for root, dirs, files in os.walk('modulos_prueba'):
        if '__pycache__' in root: continue
        for file in files:
            if file.startswith('mod_') and file.endswith('.py'):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8') as f:
                        lines = f.readlines()
                    
                    new_lines = []
                    skip_mode = False
                    
                    for line in lines:
                        # check if we hit one of the functions to remove
                        if line.startswith('def _get(') or line.startswith('def _post(') or \
                           line.startswith('def _put(') or line.startswith('def _delete(') or \
                           line.startswith('def _badge(') or line.startswith('def _color_estatus('):
                            skip_mode = True
                            continue
                        
                        if skip_mode:
                            # if we are in skip mode, we keep skipping until we hit a non-indented line that isn't empty or comment
                            if line.strip() == '' or line.startswith(' ') or line.startswith('\t') or line.startswith('#') or line.startswith('\"\"\"'):
                                continue
                            else:
                                skip_mode = False
                        
                        if not skip_mode:
                            new_lines.append(line)
                            
                    # Add import if it's not there
                    content = "".join(new_lines)
                    if "import _get, _post, _put, _delete, _badge, _color_estatus" not in content:
                        # find where to insert
                        insert_idx = 0
                        for i, line in enumerate(new_lines):
                            if line.startswith('import ') or line.startswith('from '):
                                insert_idx = i
                        new_lines.insert(insert_idx + 1, import_stmt)
                    
                    with open(path, 'w', encoding='utf-8') as f:
                        f.writelines(new_lines)
                    print(f"Refactored UI functions in {file}")
                except Exception as e:
                    print(f"Error in {file}: {e}")

if __name__ == '__main__':
    clean_and_import()

