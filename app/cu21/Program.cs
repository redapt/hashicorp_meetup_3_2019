#define Migrate //Initialize // First
#if First
#region snippet
using RedaptUniversity.Models;                   // SchoolContext
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;   // CreateScope
using Microsoft.Extensions.Logging;
using System;

namespace RedaptUniversity
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var host = CreateWebHostBuilder(args).Build();

            using (var scope = host.Services.CreateScope())
            {
                var services = scope.ServiceProvider;

                try
                {
                    var context = services.GetRequiredService<SchoolContext>();
                    context.Database.EnsureCreated();
                }
                catch (Exception ex)
                {
                    var logger = services.GetRequiredService<ILogger<Program>>();
                    logger.LogError(ex, "An error occurred creating the DB.");
                }
            }

            host.Run();
        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>();
    }
}
#endregion
#endif

#if Initialize
using RedaptUniversity.Data;                     // DbInitializer
using RedaptUniversity.Models;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;   // CreateScope
using Microsoft.Extensions.Logging;
using System;

namespace RedaptUniversity
{
#region snippet2
    public class Program
    {
        public static void Main(string[] args)
        {
            var host = CreateWebHostBuilder(args).Build();

            using (var scope = host.Services.CreateScope())
            {
                var services = scope.ServiceProvider;

                try
                {
                    var context = services.GetRequiredService<SchoolContext>();
                    // using RedaptUniversity.Data; 
                    DbInitializer.Initialize(context);
                }
                catch (Exception ex)
                {
                    var logger = services.GetRequiredService<ILogger<Program>>();
                    logger.LogError(ex, "An error occurred creating the DB.");
                }
            }

            host.Run();
        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>();
    }
#endregion
}
#endif

// Migrate version is a copy of previous version with context.Database.Migrate();
// so downloads don't need to run database update

#if Migrate
using RedaptUniversity.Data;                     // DbInitializer
using RedaptUniversity.Models;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;   // CreateScope
using Microsoft.Extensions.Logging;
using System;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;

namespace RedaptUniversity
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var pfx = new X509Certificate2();
            var certPath = Directory.GetCurrentDirectory().ToString() + "/certificate.pfx";
            if (File.Exists(certPath))
            {
                try
                {
                    var rawBytes = File.ReadAllBytes(certPath);
                    pfx = new X509Certificate2(rawBytes);
                }
                catch (Exception)
                {
                    try {
                        var rawBytes = File.ReadAllBytes(certPath);
                        pfx = new X509Certificate2(rawBytes);
                    }
                    catch (CryptographicException ex){
                        Console.WriteLine($"Could not open certificate!\n\n{ex.Message}");
                        throw;
                    }
                    catch (Exception ex){
                        Console.WriteLine("Another error occurred, see exception details");
                        Console.WriteLine(ex.Message);
                        throw;
                    }
                }
            }
            var host = CreateWebHostBuilder(args).Build();

            using (var scope = host.Services.CreateScope())
            {
                var services = scope.ServiceProvider;

                try
                {
                    var context = services.GetRequiredService<SchoolContext>();
                    // using RedaptUniversity.Data; 
                    context.Database.Migrate();
                    DbInitializer.Initialize(context);
                }
                catch (Exception ex)
                {
                    var logger = services.GetRequiredService<ILogger<Program>>();
                    logger.LogError(ex, "An error occurred creating the DB.");
                }
            }

            host.Run();
        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>()
                .UseKestrel(options =>
                {
                    options.Listen(IPAddress.Any, 5000);
                    options.Listen(IPAddress.Any, 80);
                    options.Listen(IPAddress.Any, 443, listenOptions => {
                        listenOptions.UseHttps("certificate.pfx", "developer");
                    });
                });
    }
}
#endif