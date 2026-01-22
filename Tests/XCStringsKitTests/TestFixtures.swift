import Foundation

/// Test fixtures for xcstrings file testing
enum TestFixtures {
    /// Empty xcstrings file
    static let empty = """
    {
      "sourceLanguage": "en",
      "strings": {},
      "version": "1.0"
    }
    """

    /// Single key with single language
    static let singleKeySingleLang = """
    {
      "sourceLanguage": "en",
      "strings": {
        "Hello": {
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": "Hello"
              }
            }
          }
        }
      },
      "version": "1.0"
    }
    """

    /// Single key with multiple languages
    static let singleKeyMultipleLangs = """
    {
      "sourceLanguage": "en",
      "strings": {
        "Hello": {
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": "Hello"
              }
            },
            "ja": {
              "stringUnit": {
                "state": "translated",
                "value": "こんにちは"
              }
            },
            "de": {
              "stringUnit": {
                "state": "translated",
                "value": "Hallo"
              }
            }
          }
        }
      },
      "version": "1.0"
    }
    """

    /// Multiple keys with partial translations
    static let multipleKeysPartialTranslations = """
    {
      "sourceLanguage": "en",
      "strings": {
        "Hello": {
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": "Hello"
              }
            },
            "ja": {
              "stringUnit": {
                "state": "translated",
                "value": "こんにちは"
              }
            }
          }
        },
        "Goodbye": {
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": "Goodbye"
              }
            }
          }
        },
        "Welcome": {
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": "Welcome"
              }
            },
            "ja": {
              "stringUnit": {
                "state": "translated",
                "value": "ようこそ"
              }
            },
            "de": {
              "stringUnit": {
                "state": "translated",
                "value": "Willkommen"
              }
            }
          }
        }
      },
      "version": "1.0"
    }
    """

    /// Keys with comments
    static let withComments = """
    {
      "sourceLanguage": "en",
      "strings": {
        "Hello": {
          "comment": "Greeting message shown on home screen",
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": "Hello"
              }
            }
          }
        },
        "Save": {
          "comment": "Button label for saving data",
          "extractionState": "manual",
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": "Save"
              }
            }
          }
        }
      },
      "version": "1.0"
    }
    """

    /// Different source language (Japanese)
    static let japaneseSource = """
    {
      "sourceLanguage": "ja",
      "strings": {
        "こんにちは": {
          "localizations": {
            "ja": {
              "stringUnit": {
                "state": "translated",
                "value": "こんにちは"
              }
            },
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": "Hello"
              }
            }
          }
        }
      },
      "version": "1.0"
    }
    """

    /// Many keys (10 keys)
    static let manyKeys = """
    {
      "sourceLanguage": "en",
      "strings": {
        "Key1": { "localizations": { "en": { "stringUnit": { "state": "translated", "value": "Value1" } } } },
        "Key2": { "localizations": { "en": { "stringUnit": { "state": "translated", "value": "Value2" } } } },
        "Key3": { "localizations": { "en": { "stringUnit": { "state": "translated", "value": "Value3" } } } },
        "Key4": { "localizations": { "en": { "stringUnit": { "state": "translated", "value": "Value4" } } } },
        "Key5": { "localizations": { "en": { "stringUnit": { "state": "translated", "value": "Value5" } } } },
        "Key6": { "localizations": { "en": { "stringUnit": { "state": "translated", "value": "Value6" } }, "ja": { "stringUnit": { "state": "translated", "value": "値6" } } } },
        "Key7": { "localizations": { "en": { "stringUnit": { "state": "translated", "value": "Value7" } }, "ja": { "stringUnit": { "state": "translated", "value": "値7" } } } },
        "Key8": { "localizations": { "en": { "stringUnit": { "state": "translated", "value": "Value8" } }, "ja": { "stringUnit": { "state": "translated", "value": "値8" } } } },
        "Key9": { "localizations": { "en": { "stringUnit": { "state": "translated", "value": "Value9" } } } },
        "Key10": { "localizations": { "en": { "stringUnit": { "state": "translated", "value": "Value10" } } } }
      },
      "version": "1.0"
    }
    """

    /// Keys with special characters
    static let specialCharacters = """
    {
      "sourceLanguage": "en",
      "strings": {
        "Hello, %@!": {
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": "Hello, %@!"
              }
            },
            "ja": {
              "stringUnit": {
                "state": "translated",
                "value": "こんにちは、%@！"
              }
            }
          }
        },
        "Items: %lld": {
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": "Items: %lld"
              }
            }
          }
        },
        "Line1\\\\nLine2": {
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": "Line1\\\\nLine2"
              }
            }
          }
        }
      },
      "version": "1.0"
    }
    """

    /// Keys with empty localizations
    static let emptyLocalizations = """
    {
      "sourceLanguage": "en",
      "strings": {
        "NoTranslation": {
          "comment": "This key has no translations yet"
        },
        "HasTranslation": {
          "localizations": {
            "en": {
              "stringUnit": {
                "state": "translated",
                "value": "Has Translation"
              }
            }
          }
        }
      },
      "version": "1.0"
    }
    """

    /// Many languages (5+ languages)
    static let manyLanguages = """
    {
      "sourceLanguage": "en",
      "strings": {
        "Hello": {
          "localizations": {
            "en": { "stringUnit": { "state": "translated", "value": "Hello" } },
            "ja": { "stringUnit": { "state": "translated", "value": "こんにちは" } },
            "de": { "stringUnit": { "state": "translated", "value": "Hallo" } },
            "fr": { "stringUnit": { "state": "translated", "value": "Bonjour" } },
            "es": { "stringUnit": { "state": "translated", "value": "Hola" } },
            "zh-Hans": { "stringUnit": { "state": "translated", "value": "你好" } },
            "ko": { "stringUnit": { "state": "translated", "value": "안녕하세요" } }
          }
        }
      },
      "version": "1.0"
    }
    """

    /// Various translation states
    static let variousStates = """
    {
      "sourceLanguage": "en",
      "strings": {
        "Translated": {
          "localizations": {
            "en": { "stringUnit": { "state": "translated", "value": "Translated" } },
            "ja": { "stringUnit": { "state": "translated", "value": "翻訳済み" } }
          }
        },
        "NeedsReview": {
          "localizations": {
            "en": { "stringUnit": { "state": "translated", "value": "Needs Review" } },
            "ja": { "stringUnit": { "state": "needs_review", "value": "レビュー必要" } }
          }
        },
        "New": {
          "localizations": {
            "en": { "stringUnit": { "state": "new", "value": "New" } }
          }
        }
      },
      "version": "1.0"
    }
    """

    /// Keys with stale extraction state
    static let withStaleKeys = """
    {
      "sourceLanguage": "en",
      "strings": {
        "ActiveKey": {
          "localizations": {
            "en": { "stringUnit": { "state": "translated", "value": "Active" } }
          }
        },
        "StaleKey1": {
          "extractionState": "stale",
          "localizations": {
            "en": { "stringUnit": { "state": "translated", "value": "Stale 1" } }
          }
        },
        "StaleKey2": {
          "extractionState": "stale",
          "localizations": {
            "en": { "stringUnit": { "state": "translated", "value": "Stale 2" } },
            "ja": { "stringUnit": { "state": "translated", "value": "古い2" } }
          }
        },
        "ManualKey": {
          "extractionState": "manual",
          "localizations": {
            "en": { "stringUnit": { "state": "translated", "value": "Manual" } }
          }
        }
      },
      "version": "1.0"
    }
    """
}

/// Test helper utilities
enum TestHelper {
    /// Create a temporary file and return its path
    static func createTempFile(content: String) throws -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let path = tempDir.appendingPathComponent("test_\(UUID().uuidString).xcstrings").path
        try content.write(toFile: path, atomically: true, encoding: .utf8)
        return path
    }

    /// Remove temporary file
    static func removeTempFile(at path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }
}
