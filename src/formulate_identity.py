#!/usr/bin/env python3
"""
Identity Formulator - Component-Based Identity Generation
Combines hardware components to create realistic, unique system identities
"""

import yaml
import json
import random
import secrets
import sys
from typing import Dict, List, Optional

DATABASE_FILE = "../config/hardware_database.yml"
OUTPUT_CONFIG = "../config/identity_config.json"

class IdentityFormulator:
    def __init__(self):
        self.db = self.load_database()
        
    def load_database(self) -> Dict:
        """Load hardware component database"""
        try:
            with open(DATABASE_FILE, 'r') as f:
                return yaml.safe_load(f)
        except FileNotFoundError:
            print(f"❌ Error: {DATABASE_FILE} not found!")
            sys.exit(1)
        except yaml.YAMLError as e:
            print(f"❌ Error parsing YAML: {e}")
            sys.exit(1)
    
    def generate_serial(self, prefix: str, entropy: str = "medium") -> str:
        """Generate realistic serial number"""
        if entropy == "low":
            suffix = secrets.token_hex(2).upper()  # 4 hex chars
        elif entropy == "high":
            suffix = secrets.token_hex(4).upper()  # 8 hex chars
        else:  # medium
            suffix = secrets.token_hex(3).upper()  # 6 hex chars
        
        return f"{prefix}{suffix}"
    
    def generate_mac(self, oui: str, strategy: str = "oui_preserve") -> str:
        """Generate MAC address with specified strategy"""
        if strategy == "full":
            # Completely random MAC
            mac_bytes = [secrets.randbelow(256) for _ in range(6)]
            return ":".join(f"{b:02x}" for b in mac_bytes)
        elif strategy == "partial":
            # Keep first 2 bytes of OUI, randomize rest
            oui_bytes = oui.split(":")[:2]
            random_bytes = [secrets.randbelow(256) for _ in range(4)]
            all_bytes = oui_bytes + [f"{b:02x}" for b in random_bytes]
            return ":".join(all_bytes)
        else:  # oui_preserve
            # Keep OUI, randomize last 3 bytes
            oui_part = oui
            random_part = ":".join(f"{secrets.randbelow(256):02x}" for _ in range(3))
            return f"{oui_part}:{random_part}"
    
    def generate_uuid(self) -> str:
        """Generate UUID"""
        return str(secrets.token_hex(16))
    
    def generate_boot_id(self) -> str:
        """Generate boot ID in UUID format"""
        hex_str = secrets.token_hex(16)
        # Format as UUID: 8-4-4-4-12
        return f"{hex_str[:8]}-{hex_str[8:12]}-{hex_str[12:16]}-{hex_str[16:20]}-{hex_str[20:32]}"
    
    def check_compatibility(self, cpu_id: str, gpu_id: str, mb_id: str) -> bool:
        """Check if component combination is compatible"""
        cpu = next((c for c in self.db['cpus'] if c['id'] == cpu_id), None)
        mb = next((m for m in self.db['motherboards'] if m['id'] == mb_id), None)
        
        if not cpu or not mb:
            return False
        
        # Check category compatibility (laptop/desktop)
        cpu_cat = cpu.get('category', '')
        mb_cat = mb.get('category', '')
        
        if 'laptop' in cpu_cat and 'laptop' not in mb_cat:
            return False
        if 'desktop' in cpu_cat and 'desktop' not in mb_cat:
            return False
        
        return True
    
    def formulate_from_preset(self, preset_name: str, strategy: str = "moderate") -> Dict:
        """Create identity from preset profile"""
        preset = next((p for p in self.db['preset_profiles'] if p['name'] == preset_name), None)
        if not preset:
            print(f"❌ Preset '{preset_name}' not found!")
            print(f"Available presets: {[p['name'] for p in self.db['preset_profiles']]}")
            sys.exit(1)
        
        components = preset['components']
        return self.formulate_from_components(
            components['cpu'],
            components['gpu'],
            components['motherboard'],
            components['network'],
            components['storage'],
            components['os'],
            strategy
        )
    
    def formulate_random(self, strategy: str = "moderate") -> Dict:
        """Create random identity with specified strategy"""
        max_attempts = 50
        for _ in range(max_attempts):
            cpu = random.choice(self.db['cpus'])
            gpu = random.choice(self.db['gpus'])
            mb = random.choice(self.db['motherboards'])
            network = random.choice(self.db['network_interfaces'])
            storage = random.choice(self.db['storage_devices'])
            os_choice = random.choice(self.db['operating_systems'])
            
            if self.check_compatibility(cpu['id'], gpu['id'], mb['id']):
                return self.formulate_from_components(
                    cpu['id'], gpu['id'], mb['id'],
                    network['id'], storage['id'], os_choice['id'],
                    strategy
                )
        
        print("⚠️  Warning: Could not find compatible random combination, using preset")
        return self.formulate_from_preset('workstation_laptop', strategy)
    
    def formulate_from_components(
        self,
        cpu_id: str,
        gpu_id: str,
        mb_id: str,
        network_id: str,
        storage_id: str,
        os_id: str,
        strategy: str = "moderate"
    ) -> Dict:
        """Create identity from specific component IDs"""
        
        # Get components
        cpu = next((c for c in self.db['cpus'] if c['id'] == cpu_id), None)
        gpu = next((g for g in self.db['gpus'] if g['id'] == gpu_id), None)
        mb = next((m for m in self.db['motherboards'] if m['id'] == mb_id), None)
        network = next((n for n in self.db['network_interfaces'] if n['id'] == network_id), None)
        storage = next((s for s in self.db['storage_devices'] if s['id'] == storage_id), None)
        os_choice = next((o for o in self.db['operating_systems'] if o['id'] == os_id), None)
        
        # Get environment components (random selection)
        locale = random.choice(self.db['locales'])
        timezone = random.choice(self.db['timezones'])
        
        # Get battery (only for laptop motherboards)
        battery = None
        is_laptop = 'laptop' in mb.get('category', '')
        if is_laptop:
            # Match battery category to motherboard category if possible
            mb_cat = mb.get('category', '')
            matching_batteries = [b for b in self.db['batteries'] if mb_cat.replace('laptop_', 'laptop_') in b.get('category', '')]
            battery = random.choice(matching_batteries) if matching_batteries else random.choice(self.db['batteries'])
        
        # Get memory configuration (match to motherboard category)
        mb_cat = mb.get('category', '')
        if 'budget' in mb_cat or 'laptop_budget' in mb_cat:
            memory_choices = [m for m in self.db['memory_configs'] if 'budget' in m.get('category', '')]
        elif 'premium' in mb_cat or 'high_end' in mb_cat or 'enthusiast' in mb_cat:
            memory_choices = [m for m in self.db['memory_configs'] if m.get('category', '') in ['high_performance', 'high_end', 'enthusiast', 'laptop_premium']]
        elif 'workstation' in mb_cat:
            memory_choices = [m for m in self.db['memory_configs'] if 'workstation' in m.get('category', '')]
        else:
            memory_choices = [m for m in self.db['memory_configs'] if 'mainstream' in m.get('category', '') or 'laptop_mainstream' in m.get('category', '')]
        
        memory = random.choice(memory_choices) if memory_choices else random.choice(self.db['memory_configs'])
        
        # Get display configuration (laptop vs desktop)
        if is_laptop:
            display_choices = [d for d in self.db['displays'] if 'laptop' in d.get('category', '')]
        else:
            display_choices = [d for d in self.db['displays'] if 'desktop' in d.get('category', '')]
        
        display = random.choice(display_choices) if display_choices else random.choice(self.db['displays'])
        
        if not all([cpu, gpu, mb, network, storage, os_choice]):
            print("❌ Error: One or more component IDs not found!")
            sys.exit(1)
        
        # Get strategy settings
        strat_config = self.db['randomization_strategies'].get(strategy, 
                                                                self.db['randomization_strategies']['moderate'])
        
        # Generate unique identifiers
        machine_id = self.generate_uuid()
        product_uuid = self.generate_boot_id()
        boot_id = self.generate_boot_id()
        random_uuid = self.generate_boot_id()
        
        # Generate serial numbers
        product_serial = self.generate_serial("SN-" + mb['product_name'][:4].upper(), strat_config['serial_entropy'])
        board_serial = self.generate_serial("MB-", strat_config['serial_entropy'])
        chassis_serial = self.generate_serial("CH-", strat_config['serial_entropy'])
        sda_serial = self.generate_serial(storage['serial_prefix'], strat_config['serial_entropy'])
        nvme_serial = self.generate_serial(storage['serial_prefix'], strat_config['serial_entropy'])
        
        # Generate MAC addresses
        mac_suffix = self.generate_mac(network['mac_oui'], strat_config['mac_randomize']).split(':')[-3:]
        mac_suffix_str = ':'.join(mac_suffix)
        
        # Build network interfaces
        network_interfaces = {
            "eth0": network['mac_oui'],
            "wlan0": network['mac_oui'],  # Could add second network card logic
        }
        
        # Generate hostname
        hostname_parts = [
            mb['product_name'].split()[0].lower(),
            cpu['model'].split()[2].lower().replace('(tm)', ''),
            secrets.token_hex(2)
        ]
        hostname = '-'.join(hostname_parts)[:32]  # Limit length
        
        # Create profile name
        profile_name = f"{mb['product_name'].split()[0]}_{cpu['model'].split()[3]}_{secrets.token_hex(2)}"
        
        # Build identity config
        identity = {
            "version": "2.0",
            "identity_profile": profile_name,
            "hostname": hostname,
            "_id_suffix": mac_suffix_str.replace(':', '')[:2],  # Use last 2 chars of MAC
            
            "hardware": {
                "machine_id": machine_id[:32],
                "product_uuid": product_uuid,
                "product_serial": product_serial,
                "board_serial": board_serial,
                "chassis_serial": chassis_serial,
                "product_name": mb['product_name'],
                "board_name": mb['board_name'],
                "board_vendor": mb['board_vendor'],
                "bios_vendor": mb['bios_vendor'],
                "bios_version": mb['bios_version'],
                "bios_date": mb['bios_date']
            },
            
            "cpu": {
                "model": cpu['model'],
                "cores": cpu['cores'],
                "threads": cpu['threads'],
                "vendor_id": cpu['vendor_id'],
                "mhz": cpu['mhz'],
                "cache_size": cpu['cache_size']
            },
            
            "network": {
                "interfaces": network_interfaces
            },
            
            "storage": {
                "sda_serial": sda_serial,
                "nvme_serial": nvme_serial,
                "sda_model": storage['model'],
                "nvme_model": storage['model']
            },
            
            "os": {
                "name": os_choice['name'],
                "version": os_choice['version'],
                "kernel_release": os_choice['kernel_release'],
                "kernel_version": os_choice['kernel_version']
            },
            
            "gpu": {
                "nvidia_vendor": gpu['vendor'] if gpu['type'] == 'nvidia' else "0x10de",
                "nvidia_device": gpu['device'] if gpu['type'] == 'nvidia' else "0x1c8d",
                "intel_vendor": gpu['vendor'] if gpu['type'] == 'intel' else "0x8086",
                "intel_device": gpu['device'] if gpu['type'] == 'intel' else "0x3e9b"
            },
            
            "boot": {
                "boot_id": boot_id,
                "random_uuid": random_uuid
            },
            
            "environment": {
                "locale": locale['locale'],
                "language": locale['language'],
                "timezone": timezone['timezone'],
                "display": ":0"
            },
            
            "battery": {
                "has_battery": is_laptop,
                "manufacturer": battery['manufacturer'] if battery else "N/A",
                "model": battery['model'] if battery else "N/A",
                "technology": battery['technology'] if battery else "N/A",
                "capacity_wh": battery['capacity_wh'] if battery else 0,
                "voltage_v": battery['voltage_v'] if battery else 0,
                "cells": battery['cells'] if battery else 0
            },
            
            "memory": {
                "size_gb": memory['size_gb'],
                "size_kb": memory['size_kb'],
                "speed_mhz": memory['speed_mhz'],
                "type": memory['type'],
                "manufacturer": memory['manufacturer'],
                "model": memory['model']
            },
            
            "display": {
                "name": display['name'],
                "resolution": display['resolution'],
                "width": display['width'],
                "height": display['height'],
                "refresh_rate": display['refresh_rate'],
                "manufacturer": display['manufacturer'],
                "model": display['model'],
                "diagonal_inches": display['diagonal_inches'],
                "panel_type": display['panel_type']
            },
            
            "_metadata": {
                "generated_by": "formulate_identity.py",
                "strategy": strategy,
                "components_used": {
                    "cpu": cpu_id,
                    "gpu": gpu_id,
                    "motherboard": mb_id,
                    "network": network_id,
                    "storage": storage_id,
                    "os": os_id
                }
            }
        }
        
        return identity
    
    def save_identity(self, identity: Dict, filename: str = OUTPUT_CONFIG):
        """Save generated identity to file"""
        with open(filename, 'w') as f:
            json.dump(identity, f, indent=2)
        print(f"✅ Identity saved to {filename}")
    
    def list_components(self):
        """List all available components"""
        print("\n" + "="*60)
        print("📦 AVAILABLE HARDWARE COMPONENTS")
        print("="*60)
        
        print(f"\n🖥️  CPUs ({len(self.db['cpus'])}):")
        for cpu in self.db['cpus']:
            print(f"  • {cpu['id']}: {cpu['model']} ({cpu['cores']}C/{cpu['threads']}T)")
        
        print(f"\n🎮 GPUs ({len(self.db['gpus'])}):")
        for gpu in self.db['gpus']:
            print(f"  • {gpu['id']}: {gpu['name']}")
        
        print(f"\n🔧 Motherboards ({len(self.db['motherboards'])}):")
        for mb in self.db['motherboards']:
            print(f"  • {mb['id']}: {mb['product_name']}")
        
        print(f"\n🌐 Network ({len(self.db['network_interfaces'])}):")
        for net in self.db['network_interfaces']:
            print(f"  • {net['id']}: {net['manufacturer']} {net['chipset']}")
        
        print(f"\n💾 Storage ({len(self.db['storage_devices'])}):")
        for storage in self.db['storage_devices']:
            print(f"  • {storage['id']}: {storage['model']}")
        
        print(f"\n🐧 Operating Systems ({len(self.db['operating_systems'])}):")
        for os_item in self.db['operating_systems']:
            print(f"  • {os_item['id']}: {os_item['name']} {os_item['version']}")
        
        print(f"\n🎯 Preset Profiles ({len(self.db['preset_profiles'])}):")
        for preset in self.db['preset_profiles']:
            print(f"  • {preset['name']}: {preset['description']}")
        
        print(f"\n📊 Statistics:")
        print(f"  • Total unique combinations: {self.db['metadata']['possible_combinations']:,}")
        print(f"  • With randomization: {self.db['metadata']['practical_unique_identities']}")
        print("="*60 + "\n")


def main():
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Formulate unique system identities from hardware components"
    )
    
    subparsers = parser.add_subparsers(dest='command', help='Commands')
    
    # List command
    subparsers.add_parser('list', help='List all available components')
    
    # Preset command
    preset_parser = subparsers.add_parser('preset', help='Use preset profile')
    preset_parser.add_argument('name', help='Preset profile name')
    preset_parser.add_argument('--strategy', choices=['conservative', 'moderate', 'aggressive'],
                              default='moderate', help='Randomization strategy')
    
    # Random command
    random_parser = subparsers.add_parser('random', help='Generate random identity')
    random_parser.add_argument('--strategy', choices=['conservative', 'moderate', 'aggressive'],
                              default='moderate', help='Randomization strategy')
    
    # Custom command
    custom_parser = subparsers.add_parser('custom', help='Create custom identity')
    custom_parser.add_argument('--cpu', required=True, help='CPU ID')
    custom_parser.add_argument('--gpu', required=True, help='GPU ID')
    custom_parser.add_argument('--motherboard', required=True, help='Motherboard ID')
    custom_parser.add_argument('--network', required=True, help='Network interface ID')
    custom_parser.add_argument('--storage', required=True, help='Storage device ID')
    custom_parser.add_argument('--os', required=True, help='Operating system ID')
    custom_parser.add_argument('--strategy', choices=['conservative', 'moderate', 'aggressive'],
                              default='moderate', help='Randomization strategy')
    
    args = parser.parse_args()
    
    formulator = IdentityFormulator()
    
    if args.command == 'list':
        formulator.list_components()
        
    elif args.command == 'preset':
        print(f"\n🎯 Formulating identity from preset: {args.name}")
        print(f"   Strategy: {args.strategy}")
        identity = formulator.formulate_from_preset(args.name, args.strategy)
        formulator.save_identity(identity)
        print(f"\n✨ Generated identity: {identity['identity_profile']}")
        print(f"   Hostname: {identity['hostname']}")
        print(f"   CPU: {identity['cpu']['model']}")
        print(f"   GPU: Configured")
        
    elif args.command == 'random':
        print(f"\n🎲 Formulating random identity")
        print(f"   Strategy: {args.strategy}")
        identity = formulator.formulate_random(args.strategy)
        formulator.save_identity(identity)
        print(f"\n✨ Generated identity: {identity['identity_profile']}")
        print(f"   Hostname: {identity['hostname']}")
        print(f"   CPU: {identity['cpu']['model']}")
        
    elif args.command == 'custom':
        print(f"\n🔧 Formulating custom identity")
        identity = formulator.formulate_from_components(
            args.cpu, args.gpu, args.motherboard,
            args.network, args.storage, args.os,
            args.strategy
        )
        formulator.save_identity(identity)
        print(f"\n✨ Generated identity: {identity['identity_profile']}")
        
    else:
        parser.print_help()
        return
    
    print(f"\n🚀 Next step: Run './build_identity.py' to compile")


if __name__ == "__main__":
    main()
