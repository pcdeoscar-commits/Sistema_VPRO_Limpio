import os, re

def fix_silenced_exceptions():
    pattern = re.compile(r'(\s*)except\s*(?:Exception\s*(?:as\s+\w+)?)?:?\s*\n(\s+)pass\b')
    single_line_pattern = re.compile(r'(\s*)except\s*(?:Exception\s*(?:as\s+\w+)?)?:\s*pass\b')
    
    count = 0
    for root, _, files in os.walk('.'):
        if '__pycache__' in root or '.git' in root or 'archive' in root or '.agents' in root: 
            continue
        for file in files:
            if file.endswith('.py') and file not in ('api_core.py', 'app_main.py', 'refactor_errors.py'):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    def replacer(match):
                        indent = match.group(1)
                        inner_indent = match.group(2)
                        safe_name = os.path.basename(path)
                        return f'{indent}except Exception as e:\n{inner_indent}print(f"⚠️ SILENCED ERROR in {safe_name}: {{e}}")'
                        
                    def single_replacer(match):
                        indent = match.group(1)
                        safe_name = os.path.basename(path)
                        return f'{indent}except Exception as e: print(f"⚠️ SILENCED ERROR in {safe_name}: {{e}}")'
                        
                    new_content, subs = re.subn(pattern, replacer, content)
                    new_content, subs2 = re.subn(single_line_pattern, single_replacer, new_content)
                    
                    if subs > 0 or subs2 > 0:
                        with open(path, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                        print(f'Fixed {subs + subs2} occurrences in {path}')
                        count += (subs + subs2)
                except Exception as ex:
                    print(f'Error processing {path}: {ex}')
    print(f'Total fixed: {count}')

if __name__ == '__main__':
    fix_silenced_exceptions()

