#!/usr/bin/env python3

import asyncio
import serial_asyncio
import subprocess
import sys
import os
import re
from typing import Optional

async def get_serial_port() -> str:
    """Асинхронно получает COM-порт из конфигурационного файла."""
    config_file = '/etc/dksl-90-vars'
    try:
        with open(config_file, 'r') as f:
            content = f.read()
            match = re.search(r'tty\s*=\s*(\w+)', content)
            if match:
                port = "/dev/" + match.group(1)
                print(f"Use COM port: {port}", flush=True)
                return port
            else:
                print(f"Var tty not found in file {config_file}", file=sys.stderr, flush=True)
                sys.exit(1)
    except FileNotFoundError:
        print(f"Config file {config_file} not found", file=sys.stderr, flush=True)
        sys.exit(1)

PATTERN = bytes([0xAA, 0xCC, 0x00, 0x11, 0x00])
PATTERN_LEN = len(PATTERN)
PATTERN_XOR = 0x77  # Предварительно вычисленный XOR для PATTERN

async def execute_rest_com_script():
    """Асинхронно выполняет скрипт rest_com.sh."""
    try:
        process = await asyncio.create_subprocess_exec(
            "/bin/bash", "/etc/np_scripts/rest_com.sh",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        stdout, stderr = await process.communicate()
        if process.returncode == 0:
            print("Script rest_com.sh successfully executed", flush=True)
        else:
            print(f"Script failed with error: {stderr.decode()}", file=sys.stderr, flush=True)
    except FileNotFoundError:
        print("Script file not found", file=sys.stderr, flush=True)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr, flush=True)

async def handle_serial_data(reader: asyncio.StreamReader):
    """Обрабатывает данные с последовательного порта."""
    buffer = bytes()
    print("Default button service monitor started", flush=True)
    
    try:
        while True:
            # Асинхронное чтение данных
            data = await reader.read(1024)
            if not data:
                await asyncio.sleep(0.1)
                continue
                
            buffer += data
            
            while len(buffer) >= PATTERN_LEN + 1:
                if buffer[:PATTERN_LEN] == PATTERN:
                    next_byte = buffer[PATTERN_LEN]
                    
                    if next_byte == PATTERN_XOR:
                        await execute_rest_com_script()
                    
                    buffer = buffer[PATTERN_LEN + 1:]
                else:
                    buffer = buffer[1:]
    
    except Exception as e:
        print(f"Critical error: {e}", file=sys.stderr, flush=True)
        raise

async def main():
    """Основная асинхронная функция."""
    try:
        port = await get_serial_port()
        reader, writer = await serial_asyncio.open_serial_connection(
            url=port,
            baudrate=115200,
            # Параметры ниже нужно задавать через SerialConfig
            parity='N',  # 'N' для None, 'E' для Even, 'O' для Odd
            stopbits=1,  # 1 или 2
            bytesize=8
        )
        print(f"COM port successfully opened {port}", flush=True)
        
        await handle_serial_data(reader)
        
    except KeyboardInterrupt:
        print("\nService finished", flush=True)
    except Exception as e:
        print(f"Initialization error: {e}", file=sys.stderr, flush=True)
        sys.exit(1)
    finally:
        if 'writer' in locals():
            writer.close()
            await writer.wait_closed()
        print("COM port closed", flush=True)

if __name__ == "__main__":
    asyncio.run(main())
